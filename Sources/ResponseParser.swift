//
//  ResponseParser.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-12-23.
//

import Foundation

extension HTTPURLResponse {
    static var successfulStatusCode: Range<Int> {
        return 200..<300
    }
}

public struct ResponseParser<Unpacker: DataUnpacker> {
    private let unpacker: Unpacker

    public init(unpacker: Unpacker) {
        self.unpacker = unpacker
    }

    public func parseResponse(response: HTTPURLResponse, data: Data) throws -> CommunicatorResponse<Unpacker.DataType> {
        switch response.statusCode {
        case HTTPURLResponse.successfulStatusCode:
            let decodedData = try unpacker.unpack(data)
            let response = CommunicatorResponse(
                headers: response.allHeaderFields,
                code: response.statusCode,
                body: decodedData)

            return response

        case 400..<500:
            throw CommunicatorError.unacceptableStatusCode(.clientError(code: response.statusCode, data: data))

        default:
            throw CommunicatorError.unacceptableStatusCode(.serverError(code: response.statusCode))
        }
    }
}

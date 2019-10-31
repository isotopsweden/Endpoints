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

    public func parseResponse(response: HTTPURLResponse, data: Data) -> Result<CommunicatorResponse<Unpacker.DataType>, CommunicatorError> {
        switch response.statusCode {
        case HTTPURLResponse.successfulStatusCode:
            let unpackerResult = Result {
                CommunicatorResponse(
                    body: try unpacker.unpack(data),
                    code: response.statusCode,
                    headers: response.allHeaderFields)
            }

            return unpackerResult.mapError(CommunicatorError.unpackingError)

        case 400..<500:
            return .failure(.unacceptableStatusCode(.clientError(code: response.statusCode, data: data)))

        default:
            return .failure(.unacceptableStatusCode(.serverError(code: response.statusCode)))
        }
    }
}

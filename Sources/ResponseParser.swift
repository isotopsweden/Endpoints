//
//  ResponseParser.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-12-23.
//

import Foundation

public struct ResponseParser<Unpacker: DataUnpacker> {
    private let unpacker: Unpacker

    public init(unpacker: Unpacker) {
        self.unpacker = unpacker
    }

    public func parseResponse(response: HTTPURLResponse, data: Data) throws -> Unpacker.DataType {
        switch response.statusCode {
        case HTTPURLResponse.successfulStatusCode:
            return try unpacker.unpack(data)
        case 400..<500:
            throw CommunicatorError.unacceptableStatusCode(.clientError(code: response.statusCode, data: data))
        default:
            throw CommunicatorError.unacceptableStatusCode(.serverError(code: response.statusCode))
        }
    }
}

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
        return try unpacker.unpack(data)
    }
}

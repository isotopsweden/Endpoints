//
//  DataUnpacker.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-01-08.
//

import Foundation

public protocol DataUnpacker {
    associatedtype DataType

    func unpack(_ data: Data) throws -> DataType
}

public struct EmptyUnpacker: DataUnpacker {
    public func unpack(_ data: Data) throws {
        return
    }
}

public struct JSONUnpacker<D: Decodable>: DataUnpacker {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    public func unpack(_ data: Data) throws -> D {
        return try decoder.decode(D.self, from: data)
    }
}

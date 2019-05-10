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
    public static var defaultDecoder: JSONDecoder {
        let instance = JSONDecoder()
        instance.dateDecodingStrategy = .secondsSince1970
        instance.keyDecodingStrategy = .convertFromSnakeCase
        return instance
    }

    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONUnpacker.defaultDecoder) {
        self.decoder = decoder
    }

    public func unpack(_ data: Data) throws -> D {
        return try decoder.decode(D.self, from: data)
    }
}

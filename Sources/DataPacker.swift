//
//  DataPacker.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-01-08.
//

import Foundation

public protocol DataPacker {
    var contentTypeHeaders: [String: String] { get }

    func pack() throws -> Data?
}

public struct EmptyPacker: DataPacker {
    public let contentTypeHeaders: [String: String] = [:]

    public func pack() throws -> Data? {
        return nil
    }
}

public struct JSONPacker<E: Encodable>: DataPacker {
    public static var defaultEncoder: JSONEncoder {
        let instance = JSONEncoder()
        instance.dateEncodingStrategy = .secondsSince1970
        instance.keyEncodingStrategy = .convertToSnakeCase
        return instance
    }

    private let encodable: E
    private let encoder: JSONEncoder

    public let contentTypeHeaders: [String: String] = ["Content-Type": "application/json"]

    public init(encodable: E, encoder: JSONEncoder = JSONPacker.defaultEncoder) {
        self.encodable = encodable
        self.encoder = encoder
    }

    public func pack() throws -> Data? {
        return try encoder.encode(encodable)
    }
}

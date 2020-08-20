//
//  Decoder.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2020-06-28.
//

import Foundation

public protocol Decoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

extension JSONDecoder: Decoder {}

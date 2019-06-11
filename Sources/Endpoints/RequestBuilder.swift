//
//  RequestBuilder.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-01-08.
//

import Foundation

public struct RequestBuilder<Packer: DataPacker> {
    private let packer: Packer

    public init(packer: Packer) {
        self.packer = packer
    }

    public func buildURLRequest(url: URL, headers: [String: String], method: HTTPMethod) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers.merging(packer.contentTypeHeaders, uniquingKeysWith: { _, secondValue in
            return secondValue
        })
        request.httpMethod = method.rawValue
        request.httpBody = try packer.pack()

        return request
    }
}

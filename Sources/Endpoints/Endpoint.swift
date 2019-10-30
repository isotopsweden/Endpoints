//
//  Endpoint.swift
//  Endpoints
//
//  Created by Eric Nilsson on 2018-09-26.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

public protocol Endpoint {
    associatedtype Packer: DataPacker
    associatedtype Unpacker: DataUnpacker

    var baseURL: URL { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }

    var method: HTTPMethod { get }
    var headers: [String: String] { get }

    var packer: Packer { get }
    var unpacker: Unpacker { get }
}

public extension Endpoint {
    var queryItems: [URLQueryItem] {
        return []
    }

    var headers: [String: String] {
        return [:]
    }

    var packer: EmptyPacker {
        return EmptyPacker()
    }

    var unpacker: EmptyUnpacker {
        return EmptyUnpacker()
    }

    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false)

        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else { throw CommunicatorError.invalidURL }

        let requestBuilder = RequestBuilder(packer: packer)
        return try requestBuilder.buildURLRequest(url: url, headers: headers, method: method)
    }
}

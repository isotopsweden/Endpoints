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

    var requestBuilder: RequestBuilder<Packer> { get }
    var responseParser: ResponseParser<Unpacker> { get }
}

public extension Endpoint {
    var headers: [String: String] {
        return [:]
    }

    var requestBuilder: RequestBuilder<EmptyPacker> {
        return RequestBuilder(packer: EmptyPacker())
    }

    var responseParser: ResponseParser<EmptyUnpacker> {
        return ResponseParser(unpacker: EmptyUnpacker())
    }

    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else { throw CommunicatorError.invalidURL }

        return try requestBuilder.buildURLRequest(url: url, headers: headers, method: method)
    }
}

public extension Endpoint where Unpacker.DataType: Decodable {
    var responseParser: ResponseParser<JSONUnpacker<Unpacker.DataType>> {
        return ResponseParser(unpacker: JSONUnpacker())
    }
}

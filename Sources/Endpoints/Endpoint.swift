//
//  Endpoint.swift
//  Endpoints
//
//  Created by Eric Nilsson on 2018-09-26.
//

import Foundation

public struct Endpoint<Response> {
    public typealias Packer = () throws -> Data
    public typealias Unpacker = (Data) throws -> Response

    public var baseURL: URL
    public var path: String
    public var method: HTTPMethod = .get

    public var queryItems: [URLQueryItem] = []
    public var headers: [String: String] = [:]

    public var packer: Packer? = nil
    public var unpacker: Unpacker

    public init(
        baseURL: URL,
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        packer: Packer? = nil,
        unpacker: @escaping Unpacker
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.packer = packer
        self.unpacker = unpacker
    }
}

// MARK: - Convenience init
public extension Endpoint where Response == Void {
    init(
        baseURL: URL,
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        packer: Packer? = nil
    ) {
        self.init(
            baseURL: baseURL,
            path: path,
            method: method,
            queryItems: queryItems,
            headers: headers,
            packer: packer,
            unpacker: { _ in () })
    }
}

// MARK: - asURLRequest
public extension Endpoint {
    func asURLRequest() -> Result<URLRequest, CommunicatorError> {
        var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false)

        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let packer = packer {
            do {
                request.httpBody = try packer()
            } catch {
                return .failure(.packingError(underlyingError: error))
            }
        }

        return .success(request)
    }
}

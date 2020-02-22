//
//  Endpoint.swift
//  Endpoints
//
//  Created by Eric Nilsson on 2018-09-26.
//

import Foundation

public struct Endpoint<Response, ErrorResponse> {
    public typealias Packer = () throws -> Data
    public typealias Unpacker = (Data) throws -> Response
    public typealias ErrorUnpacker = (Data) throws -> ErrorResponse

    public var baseURL: URL
    public var path: String
    public var method: HTTPMethod = .get

    public var queryItems: [URLQueryItem] = []
    public var headers: [String: String] = [:]

    public var packer: Packer? = nil
    public var unpacker: Unpacker
    public var errorUnpacker: ErrorUnpacker
}

// MARK: - Convenience init
public extension Endpoint where Response == Void {
    init(
        baseURL: URL,
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        packer: Packer? = nil,
        errorUnpacker: @escaping ErrorUnpacker
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.packer = packer
        self.unpacker = { _ in () }
        self.errorUnpacker = errorUnpacker
    }
}

public extension Endpoint where Response == Void, ErrorResponse == Void {
    init(
        baseURL: URL,
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        packer: Packer? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.packer = packer
        self.unpacker = { _ in () }
        self.errorUnpacker = { _ in () }
    }
}

public extension Endpoint where ErrorResponse == Void {
    init(
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
        self.errorUnpacker = { _ in () }
    }
}

// MARK: - asURLRequest
public extension Endpoint {
    func asURLRequest() -> Result<URLRequest, CommunicatorError<ErrorResponse>> {
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

//
//  Endpoint.swift
//  Endpoints
//
//  Created by Eric Nilsson on 2018-09-26.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case patch = "PATCH"
    case post = "POST"
    case delete = "DELETE"
}

public protocol Endpoint {
    associatedtype ResponseType

    var baseURL: URL { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }

    var method: HTTPMethod { get }
    var headers: [String: String] { get }

    func pack() throws -> Data?

    func unpack(data: Data) throws -> ResponseType
}

// MARK: - Defaults
public extension Endpoint {
    var queryItems: [URLQueryItem] {
        return []
    }

    var headers: [String: String] {
        return [:]
    }

    func pack() throws -> Data? {
        return nil
    }
}

// MARK: - Default unpackers
public extension Endpoint where ResponseType == Void {
    func unpack(data: Data) throws -> Void {
        return ()
    }
}

public extension Endpoint where ResponseType: Decodable {
    func unpack(data: Data) throws -> ResponseType {
        let decoder = JSONDecoder()
        return try decoder.decode(ResponseType.self, from: data)
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
        request.allHTTPHeaderFields = headers

        do {
            request.httpBody = try pack()
        } catch {
            return .failure(.packingError(underlyingError: error))
        }

        return .success(request)
    }
}

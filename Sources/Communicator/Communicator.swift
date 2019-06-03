//
//  Communicator.swift
//  Endpoints
//
//  Created by Eric Nilsson on 2018-09-26.
//

import Foundation

public protocol Communicator {
    typealias CompletionHandler<ResultType> = (Result<CommunicatorResponse<ResultType>, Error>) -> Void

    @discardableResult
    func performRequest<E>(
        to endpoint: E,
        completionHandler: @escaping CompletionHandler<E.Unpacker.DataType>
        ) -> Cancellable? where E: Endpoint
}

public struct CommunicatorResponse<Body> {
    public let headers: [AnyHashable: Any]
    public let code: Int
    public let body: Body
}

public enum CommunicatorError: Error {
    case invalidURL
    case unacceptableStatusCode(ErrorReason)
    case unsupportedResponse

    public enum ErrorReason {
        case clientError(code: Int, data: Data)
        case serverError(code: Int)
    }
}

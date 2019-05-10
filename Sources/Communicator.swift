//
//  Communicator.swift
//  Endpoints
//
//  Created by Eric Nilsson on 2018-09-26.
//

import Foundation

public protocol Communicator {
    typealias CompletionHandler<ResultType, ErrorType> = (Result<CommunicatorResponse<ResultType>, CommunicatorError<ErrorType>>) -> Void

    @discardableResult
    func performRequest<E>(
        to endpoint: E,
        completionHandler: @escaping CompletionHandler<E.Unpacker.DataType, E.ErrorUnpacker.DataType>
        ) -> RequestToken? where E: Endpoint
}

public struct CommunicatorResponse<Body> {
    public let headers: [AnyHashable: Any]
    public let code: Int
    public let body: Body
}

public enum CommunicatorError<ErrorBody>: Error {
    case invalidURL
    case encodingError(EncodingError)
    case unacceptableStatusCode(ErrorReason)
    case decodingError(DecodingError)
    case unsupportedResponse
    case unknownError(Error)

    public enum ErrorReason {
        case clientError(code: Int, ErrorBody)
        case serverError(code: Int)
    }
}

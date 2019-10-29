//
//  Communicator.swift
//  Endpoints
//
//  Created by Eric Nilsson on 2018-09-26.
//

import Foundation

public protocol Communicator {
    typealias CompletionHandler<ResultType> = (Result<CommunicatorResponse<ResultType>, CommunicatorError>) -> Void

    @discardableResult
    func performRequest<E>(
        to endpoint: E,
        completionHandler: @escaping CompletionHandler<E.Unpacker.DataType>
    ) -> Cancellable? where E: Endpoint
}

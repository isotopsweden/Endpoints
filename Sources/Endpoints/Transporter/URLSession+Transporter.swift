//
//  URLSession+Transporter.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-05-25.
//

import Foundation

extension URLSessionDataTask: Cancellable {}

extension URLSession: Transporter {
    public func send(_ request: URLRequest, completionHandler: @escaping (Result<TransportationResult, CommunicatorError>) -> Void) -> Cancellable {
        let task = dataTask(with: request) { data, response, error in
            switch (response, data, error) {
            case (_, _, let error?):
                completionHandler(.failure(.networkError(underlyingError: error)))

            case (let httpResponse as HTTPURLResponse, let data?, nil):
                let result = TransportationResult(response: httpResponse, data: data)
                completionHandler(.success(result))

            case (_, _, nil):
                completionHandler(.failure(.unsupportedResponse))
            }
        }

        task.resume()

        return task
    }
}

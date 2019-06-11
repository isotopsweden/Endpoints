//
//  URLSession+Transporter.swift
//  Endpoints iOS
//
//  Created by Simon Jarbrant on 2019-05-25.
//

import Foundation

extension URLSessionDataTask: Cancellable {}

extension URLSession: Transporter {
    public func send(_ request: URLRequest, completionHandler: @escaping (Result<TransportationResult, Error>) -> Void) -> Cancellable {
        let task = dataTask(with: request) { data, response, error in
            switch (response, data, error) {
            case (_, _, let error?):
                completionHandler(.failure(error))

            case (let httpResponse as HTTPURLResponse, let data?, nil):
                let result = TransportationResult(response: httpResponse, data: data)
                completionHandler(.success(result))

            case (_, _, nil):
                completionHandler(.failure(CommunicatorError.unsupportedResponse))
            }
        }

        task.resume()

        return task
    }
}

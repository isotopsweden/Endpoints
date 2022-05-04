//
//  URLSession+Transporter.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-05-25.
//

import Foundation

extension URLSession: Transporter {
    public func send(
        _ request: URLRequest,
        completionHandler: @escaping (Result<TransporterResponse, CommunicatorError>) -> Void
    ) -> Request {
        let task = dataTask(with: request) { data, response, error in
            switch (response, data, error) {
            case (_, _, let error?):
                completionHandler(.failure(.networkError(underlyingError: error)))

            case (let httpResponse as HTTPURLResponse, let data?, nil):
                let result = TransporterResponse(response: httpResponse, data: data)
                completionHandler(.success(result))

            case (_, _, nil):
                completionHandler(.failure(.unsupportedResponse))
            }
        }

        task.resume()

        return Request(dataTask: task)
    }

    @available(iOS 15, *)
    public func send(_ request: URLRequest) async -> Result<TransporterResponse, CommunicatorError> {
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            
            guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                return .failure(.unsupportedResponse)
            }

            return .success(TransporterResponse(response: httpUrlResponse, data: data))

        } catch {
            return .failure(.networkError(underlyingError: error))
        }
    }
}

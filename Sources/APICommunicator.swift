//
//  APICommunicator.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-09-14.
//

import Foundation

public final class APICommunicator: Communicator {
    private let urlSession: URLSession
    private let callbackQueue: DispatchQueue

    private let logger: Logger?

    public init(configuration: URLSessionConfiguration = .default, callbackQueue: DispatchQueue = .main, logger: Logger? = nil) {
        self.urlSession = URLSession(configuration: configuration)
        self.callbackQueue = callbackQueue
        self.logger = logger
    }

    deinit {
        urlSession.invalidateAndCancel()
    }

    public func performRequest<E>(to endpoint: E, completionHandler: @escaping CompletionHandler<E.Unpacker.DataType, E.ErrorUnpacker.DataType>) -> RequestToken? where E: Endpoint {
        let request: URLRequest

        do {
            request = try endpoint.asURLRequest()
        } catch {
            log(error: error)

            completionHandler(.failure(.unknownError(error)))
            return nil
        }

        log(request: request, method: endpoint.method)

        let task = urlSession.dataTask(with: request) { [endpoint, callbackQueue, weak self] data, response, error in
            do {
                switch (response, data, error) {
                case (_, _, let error?):
                    throw error

                case (let httpResponse as HTTPURLResponse, let data?, nil):
                    self?.log(response: httpResponse)

                    let decodedData: E.Unpacker.DataType

                    switch httpResponse.statusCode {
                    case HTTPURLResponse.successfulStatusCode:
                        decodedData = try endpoint.responseParser.parseResponse(response: httpResponse, data: data)
                    case 400..<500:
                        let errorBody = try endpoint.errorParser.parseResponse(response: httpResponse, data: data)
                        throw CommunicatorError.unacceptableStatusCode(.clientError(code: httpResponse.statusCode, errorBody))
                    default:
                        throw CommunicatorError<E.ErrorUnpacker.DataType>.unacceptableStatusCode(.serverError(code: httpResponse.statusCode))
                    }

                    let communicatorResponse = CommunicatorResponse(
                        headers: httpResponse.allHeaderFields,
                        code: httpResponse.statusCode,
                        body: decodedData)

                    callbackQueue.async { completionHandler(.success(communicatorResponse)) }

                case (_, _, nil):
                    throw CommunicatorError<E.ErrorUnpacker.DataType>.unsupportedResponse
                }
            } catch {
                self?.log(error: error, url: request.url)

                let communicatorError: CommunicatorError<E.ErrorUnpacker.DataType>

                switch error {
                case let error as CommunicatorError<E.ErrorUnpacker.DataType>:
                    communicatorError = error
                case let error as DecodingError:
                    communicatorError = .decodingError(error)
                default:
                    communicatorError = .unknownError(error)
                }

                callbackQueue.async { completionHandler(.failure(communicatorError)) }
            }
        }

        task.resume()

        return URLSessionRequestToken(task: task)
    }

    private func log(request: URLRequest, method: HTTPMethod) {
        let urlString = request.url?.absoluteString ?? "<Missing URL>"

        logger?.log("<APICommunicator> \(method.rawValue) \(urlString)")
    }

    private func log(response: HTTPURLResponse) {
        let urlString = response.url?.absoluteString ?? "<Missing URL>"

        logger?.log("<APICommunicator> \(response.statusCode) \(urlString)")
    }

    private func log(error: Error, url: URL? = nil) {
        let urlString = url?.absoluteString ?? "<Missing URL>"

        logger?.log("<APICommunicator> \(urlString) error: \(error)")
    }
}

//
//  APICommunicator.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-09-14.
//

import Foundation

public final class APICommunicator: Communicator {
    private let transport: Transporter
    private let callbackQueue: DispatchQueue

    private let logger: Logger?

    public init(transport: Transporter = URLSession.shared, callbackQueue: DispatchQueue = .main, logger: Logger? = nil) {
        self.transport = transport
        self.callbackQueue = callbackQueue
        self.logger = logger
    }

    @discardableResult
    public func performRequest<E>(to endpoint: E, completionHandler: @escaping CompletionHandler<E.Unpacker.DataType>) -> Cancellable? where E: Endpoint {
        let request: URLRequest

        switch endpoint.asURLRequest() {
        case .success(let createdRequest):
            request = createdRequest
        case .failure(let error):
            log(error: error)
            completionHandler(.failure(error))
            return nil
        }

        log(request: request, method: endpoint.method)

        return transport.send(request) { [weak self] wrappedTransportationResult in
            let responseParseResult = wrappedTransportationResult.flatMap { transportationResult -> Result<CommunicatorResponse<E.Unpacker.DataType>, CommunicatorError> in
                let parser = ResponseParser(unpacker: endpoint.unpacker)
                return parser.parseResponse(response: transportationResult.response,
                                            data: transportationResult.data)
            }

            if case .failure(let error) = responseParseResult {
                self?.log(error: error, url: request.url)
            }

            self?.callbackQueue.async {
                completionHandler(responseParseResult)
            }
        }
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

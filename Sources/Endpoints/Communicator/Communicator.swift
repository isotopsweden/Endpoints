//
//  Communicator.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-09-14.
//

import Foundation

public final class Communicator {

    public typealias CompletionHandler<ResultType> = (Result<CommunicatorResponse<ResultType>, CommunicatorError>) -> Void

    private let transporter: Transporter
    private let callbackQueue: DispatchQueue

    private let logger: Logger?

    public init(
        transporter: Transporter = URLSession.shared,
        callbackQueue: DispatchQueue = .main,
        logger: Logger? = nil
    ) {
        self.transporter = transporter
        self.callbackQueue = callbackQueue
        self.logger = logger
    }

    @discardableResult
    public func performRequest<E>(
        to endpoint: E,
        completionHandler: @escaping CompletionHandler<E.Unpacker.DataType>
    ) -> Request? where E: Endpoint {
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

        return transporter.send(request) { [weak self] result in
            let responseParseResult = result.flatMap { transporterResponse -> Result<CommunicatorResponse<E.Unpacker.DataType>, CommunicatorError> in
                let parser = ResponseParser(unpacker: endpoint.unpacker)
                return parser.parseResponse(response: transporterResponse.urlResponse,
                                            data: transporterResponse.data)
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

        logger?.log("<Communicator> \(method.rawValue) \(urlString)")
    }

    private func log(response: HTTPURLResponse) {
        let urlString = response.url?.absoluteString ?? "<Missing URL>"

        logger?.log("<Communicator> \(response.statusCode) \(urlString)")
    }

    private func log(error: Error, url: URL? = nil) {
        let urlString = url?.absoluteString ?? "<Missing URL>"

        logger?.log("<Communicator> \(urlString) error: \(error)")
    }
}

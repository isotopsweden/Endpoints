//
//  Communicator.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-09-14.
//

import Foundation

public final class Communicator {
    public typealias CommunicatorResult<ResultType> = Result<CommunicatorResponse<ResultType>, CommunicatorError>
    public typealias CompletionHandler<ResultType> = (CommunicatorResult<ResultType>) -> Void

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
    public func performRequest<Response>(
        to endpoint: Endpoint<Response>,
        completionHandler: @escaping CompletionHandler<Response>
    ) -> Cancellable? {
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
            let communicatorResult: CommunicatorResult<Response> = result.flatMap { transporterResponse in
                return Self.parse(response: transporterResponse, unpacker: endpoint.unpacker)
            }

            if case .failure(let error) = communicatorResult {
                self?.log(error: error, url: request.url)
            }

            self?.callbackQueue.async {
                completionHandler(communicatorResult)
            }
        }
    }
}

// MARK: - Transporter response parsing
extension Communicator {
    public static func parse<Response>(
        response: TransporterResponse,
        unpacker: Endpoint<Response>.Unpacker
    ) -> Result<CommunicatorResponse<Response>, CommunicatorError> {

        switch response.urlResponse.statusCode {
        case HTTPURLResponse.successfulStatusCode:
            do {
                let communicatorResponse = CommunicatorResponse(
                    body: try unpacker(response.data),
                    code: response.urlResponse.statusCode,
                    headers: response.urlResponse.allHeaderFields)

                return .success(communicatorResponse)
            } catch {
                return .failure(.unpackingError(underlyingError: error))
            }
        case 400..<500:
            let errorReason = CommunicatorError.ErrorReason.clientError(
                code: response.urlResponse.statusCode,
                data: response.data)

            return .failure(.unacceptableStatusCode(errorReason))

        default:
            let errorReason = CommunicatorError.ErrorReason.serverError(
                code: response.urlResponse.statusCode)

            return .failure(.unacceptableStatusCode(errorReason))
        }
    }
}

// MARK: - Logging
extension Communicator {
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

//
//  Communicator.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-09-14.
//

import Foundation

extension Result where Success == TransporterResponse, Failure == TransporterError {
    func mapToCommunicatorResult<Response, ErrorResponse>(
        for endpoint: Endpoint<Response, ErrorResponse>
    ) -> Communicator.CommunicatorResult<Response, ErrorResponse> {

        switch self {
        case .success(let response):
            return Communicator.parse(
                response: response,
                unpacker: endpoint.unpacker,
                errorUnpacker: endpoint.errorUnpacker)

        case .failure(let error):
            switch error {
            case .networkError(let underlyingError):
                return .failure(.networkError(underlyingError: underlyingError))
            case .unsupportedResponse:
                return .failure(.unsupportedResponse)
            }
        }
    }
}

public final class Communicator {
    public typealias CommunicatorResult<ResultType, ErrorType> = Result<CommunicatorResponse<ResultType>, CommunicatorError<ErrorType>>
    public typealias CompletionHandler<ResultType, ErrorType> = (CommunicatorResult<ResultType, ErrorType>) -> Void

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
    public func performRequest<Response, ErrorResponse>(
        to endpoint: Endpoint<Response, ErrorResponse>,
        completionHandler: @escaping CompletionHandler<Response, ErrorResponse>
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
            let communicatorResult = result.mapToCommunicatorResult(for: endpoint)

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
    public static func parse<Response, ErrorResponse>(
        response: TransporterResponse,
        unpacker: Endpoint<Response, ErrorResponse>.Unpacker,
        errorUnpacker: Endpoint<Response, ErrorResponse>.ErrorUnpacker
    ) -> Result<CommunicatorResponse<Response>, CommunicatorError<ErrorResponse>> {

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
            do {
                let errorResponse = try errorUnpacker(response.data)
                let errorReason = CommunicatorError.ErrorReason.clientError(
                    code: response.urlResponse.statusCode,
                    response: errorResponse)

                return .failure(.unacceptableStatusCode(errorReason))
            } catch {
                return .failure(.unpackingError(underlyingError: error))
            }
        default:
            let errorReason = CommunicatorError<ErrorResponse>.ErrorReason.serverError(
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

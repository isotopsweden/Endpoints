//
//  TestTransporter.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-10-29.
//

import Foundation
import Endpoints

public class TestTransporter: Transporter {

    public typealias CompletionHandler = (Result<TransporterResponse, CommunicatorError>) -> Void

    public var enqueuedResponses: [Result<TestResponse, CommunicatorError>]

    public init(responses: [Result<TestResponse, CommunicatorError>] = []) {
        self.enqueuedResponses = responses
    }

    public func send(_ request: URLRequest, completionHandler: @escaping (Result<TransporterResponse, CommunicatorError>) -> Void) -> Cancellable {
        guard let requestURL = request.url else {
            completionHandler(.failure(.invalidURL))
            return TestCancellable()
        }

        let testResponse = enqueuedResponses.removeFirst().map { response -> TransporterResponse in
            let urlResponse = HTTPURLResponse(
                url: requestURL,
                statusCode: response.code,
                httpVersion: "HTTP/1.1",
                headerFields: response.headerFields)!

            return TransporterResponse(response: urlResponse, data: response.data)
        }

        completionHandler(testResponse)
        return TestCancellable()
    }
}

// MARK: - TestResponse
extension TestTransporter {
    public struct TestResponse {
        public var code: Int
        public var headerFields: [String: String]?
        public var data: Data

        public init(code: Int, headerFields: [String: String]? = nil, data: Data = Data()) {
            self.code = code
            self.headerFields = headerFields
            self.data = data
        }
    }
}

// MARK: - TestCancellable
extension TestTransporter {
    public class TestCancellable: Cancellable {
        public func cancel() {
            // Unused
        }
    }
}

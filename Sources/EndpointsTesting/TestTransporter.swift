//
//  TestTransporter.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-10-29.
//

import Foundation
import Endpoints

public class TestTransporter: Transporter {

    public var enqueuedResponses: [TestResponse]

    public init(responses: [TestResponse] = []) {
        self.enqueuedResponses = responses
    }

    public func send(_ request: URLRequest, completionHandler: @escaping (Result<TransportationResult, Error>) -> Void) -> Cancellable {
        guard let requestURL = request.url else {
            completionHandler(.failure(CommunicatorError.invalidURL))
            return TestCancellable()
        }

        let testResponse = enqueuedResponses.removeFirst()
        let urlResponse = HTTPURLResponse(
            url: requestURL,
            statusCode: testResponse.code,
            httpVersion: "HTTP/1.1",
            headerFields: nil)!

        let result = TransportationResult(response: urlResponse, data: testResponse.data)
        completionHandler(.success(result))

        return TestCancellable()
    }
}

// MARK: - TestResponse
extension TestTransporter {
    public struct TestResponse {
        public var code: Int
        public var data: Data

        public init(code: Int, data: Data) {
            self.code = code
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

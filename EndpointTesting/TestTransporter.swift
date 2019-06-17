//
//  TestTransporter.swift
//  EndpointTesting iOS
//
//  Created by Simon Jarbrant on 2019-06-17.
//

import Foundation
import Endpoints

public class TestTransporter: Transporter {

    public enum TestTransporterError: Error {
        case requestURLMissing
    }

    public struct TestResponse {
        public var code: Int
        public var data: Data

        public init(code: Int, data: Data) {
            self.code = code
            self.data = data
        }
    }

    public var enqueuedResponses: [TestResponse]

    public init(responses: [TestResponse] = []) {
        self.enqueuedResponses = responses
    }

    public func send(_ request: URLRequest, completionHandler: @escaping (Result<TransportationResult, Error>) -> Void) -> Cancellable {
        guard let requestURL = request.url else {
            completionHandler(.failure(TestTransporterError.requestURLMissing))
            return TestCancellable()
        }

        let responseDetails = enqueuedResponses.removeFirst()
        let response = HTTPURLResponse(url: requestURL, statusCode: responseDetails.code, httpVersion: "HTTP/1.1", headerFields: nil)
        let result = TransportationResult(response: response!, data: responseDetails.data)

        completionHandler(.success(result))

        return TestCancellable()
    }
}

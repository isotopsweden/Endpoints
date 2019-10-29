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

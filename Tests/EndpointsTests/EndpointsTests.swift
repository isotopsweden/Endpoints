//
//  EndpointsTests.swift
//  EndpointsTests
//
//  Created by Simon Jarbrant on 2019-10-29.
//

import XCTest
import EndpointsTesting

@testable import Endpoints

class EndpointsTests: XCTestCase {
    private let endpoint = Endpoint<TestMessage, Void>(
        baseURL: URL(string: "https://example.com")!,
        path: "message",
        method: .get,
        unpacker: { data in
            let decoder = JSONDecoder()
            return try decoder.decode(TestMessage.self, from: data)
    })

    func testEndpointCreatesValidURLRequest() throws {
        switch endpoint.asURLRequest() {
        case .success(let request):
            XCTAssertEqual(request.url?.absoluteString, "https://example.com/message")
            XCTAssertEqual(request.httpMethod, "GET")
        case .failure(let error):
            XCTFail("Expected URLRequest created by Endpoint to succeed, but was error: \(error)")
        }
    }

    func testCommunicatorCompletesSuccessfulRequest() throws {
        let testTransporter = TestTransporter(responses: [
            .success(.init(code: 200, data: TestFixtures.simpleMessageData))
        ])

        let communicator = Communicator(transporter: testTransporter)

        let communicatorCompletionExpectation = XCTestExpectation(description: "Communicator completion expectation")
        var expectedResult: Result<CommunicatorResponse<TestMessage>, CommunicatorError<Void>>?
        communicator.performRequest(to: endpoint) { result in
            expectedResult = result
            communicatorCompletionExpectation.fulfill()
        }

        wait(for: [communicatorCompletionExpectation], timeout: 1.0)

        assertSuccess(expectedResult, predicate: { value in
            XCTAssertEqual(value.code, 200)
            XCTAssertEqual(value.body.message, "Hi!")
        })
    }

    func testCommunicatorRespondsWithClientError() throws {
        let testTransporter = TestTransporter(responses: [
            .success(.init(code: 401, data: Data()))
        ])

        let communicator = Communicator(transporter: testTransporter)
        let communicatorCompletionExpectation = XCTestExpectation(description: "Communicator completion expectation")
        var expectedResult: Result<CommunicatorResponse<TestMessage>, CommunicatorError<Void>>?
        communicator.performRequest(to: endpoint) { result in
            expectedResult = result
            communicatorCompletionExpectation.fulfill()
        }

        wait(for: [communicatorCompletionExpectation], timeout: 1.0)

        assertFailure(expectedResult, predicate: { error in
            guard case .unacceptableStatusCode(let communicatorErrorReason) = error else {
                XCTFail("Expected received error to be a CommunicatorError.unacceptableStatusCode")
                return
            }

            if case .clientError = communicatorErrorReason {} else {
                XCTFail("Expected error reason to be .clientError")
            }
        })
    }

    func testCommunicatorRespondsWithTypedClientError() throws {
        let errorEndpoint = Endpoint<Void, TestMessage>(
            baseURL: URL(string: "https://example.com")!,
            path: "message",
            method: .get,
            errorUnpacker: { data in
                let decoder = JSONDecoder()
                return try decoder.decode(TestMessage.self, from: data)
        })

        let encoder = JSONEncoder()
        let responseData = try encoder.encode(TestMessage(message: "Authentication"))

        let testTransporter = TestTransporter(responses: [
            .success(.init(code: 401, data: responseData))
        ])

        let communicator = Communicator(transporter: testTransporter)
        let communicatorCompletionExpectation = XCTestExpectation(description: "Communicator completion expectation")
        var expectedResult: Result<CommunicatorResponse<Void>, CommunicatorError<TestMessage>>?
        communicator.performRequest(to: errorEndpoint) { result in
            expectedResult = result
            communicatorCompletionExpectation.fulfill()
        }

        wait(for: [communicatorCompletionExpectation], timeout: 1.0)

        assertFailure(expectedResult, predicate: { error in
            guard case .unacceptableStatusCode(let reason) = error else {
                XCTFail("Expected received error to be a CommunicatorError.unacceptableStatusCode")
                return
            }

            if case .clientError(let code, let message) = reason {
                XCTAssertEqual(code, 401)
                XCTAssertEqual(message.message, "Authentication")
            } else {
                XCTFail("Expected error reason to be .clientError")
            }
        })
    }
}

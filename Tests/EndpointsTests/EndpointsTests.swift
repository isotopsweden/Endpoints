//
//  EndpointsTests.swift
//  EndpointsTests
//
//  Created by Simon Jarbrant on 2019-10-29.
//

import XCTest
import EndpointsTesting

@testable import Endpoints

struct TestMessage: Decodable {
    let message: String
}

class EndpointsTests: XCTestCase {
    func testEndpointCreatesValidURLRequest() throws {
        let endpoint = TestEndpoint()
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
            TestTransporter.TestResponse(code: 200, data: TestFixtures.simpleMessageData)
        ])

        let communicator = Communicator(transporter: testTransporter)

        let communicatorCompletionExpectation = XCTestExpectation(description: "Communicator completion expectation")
        var expectedResult: Result<CommunicatorResponse<TestMessage>, CommunicatorError>?
        communicator.performRequest(to: TestEndpoint()) { result in
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
            TestTransporter.TestResponse(code: 401, data: Data())
        ])

        let communicator = Communicator(transporter: testTransporter)
        let communicatorCompletionExpectation = XCTestExpectation(description: "Communicator completion expectation")
        var expectedResult: Result<CommunicatorResponse<TestMessage>, CommunicatorError>?
        communicator.performRequest(to: TestEndpoint()) { result in
            expectedResult = result
            communicatorCompletionExpectation.fulfill()
        }

        wait(for: [communicatorCompletionExpectation], timeout: 1.0)

        assertFailure(expectedResult, predicate: { error in
            guard case .unacceptableStatusCode(let communicatorErrorReason) = error else {
                XCTFail("Expected received error to be a CommunicatorError.unacceptableStatusCode")
                return
            }

            XCTAssertEqual(communicatorErrorReason, CommunicatorError.ErrorReason.clientError(code: 401, data: Data()))
        })
    }
}

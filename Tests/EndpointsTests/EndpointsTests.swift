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
        let request = try endpoint.asURLRequest()

        XCTAssertEqual(request.url?.absoluteString, "https://example.com/message")
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func testCommunicatorCompletesSuccessfulRequest() throws {
        let testTransporter = TestTransporter(responses: [
            TestTransporter.TestResponse(code: 200, data: TestFixtures.simpleMessageData)
        ])

        let communicator = APICommunicator(transport: testTransporter)

        let communicatorCompletionExpectation = XCTestExpectation(description: "Communicator completion expectation")
        var expectedResult: Result<CommunicatorResponse<TestMessage>, Error>?
        communicator.performRequest(to: TestEndpoint()) { result in
            expectedResult = result
            communicatorCompletionExpectation.fulfill()
        }

        wait(for: [communicatorCompletionExpectation], timeout: 1.0)

        switch expectedResult {
        case .success(let response)?:
            XCTAssertEqual(response.code, 200)
            XCTAssertEqual(response.body.message, "Hi!")

        case .failure(let error)?:
            XCTFail("Expected unwrapped result to be a success, but was failure: \(error)")

        case .none:
            XCTFail("Expected expectedResult to be non-optional")
        }
    }

    func testCommunicatorRespondsWithClientError() throws {
        let testTransporter = TestTransporter(responses: [
            TestTransporter.TestResponse(code: 401, data: Data())
        ])

        let communicator = APICommunicator(transport: testTransporter)
        let communicatorCompletionExpectation = XCTestExpectation(description: "Communicator completion expectation")
        var expectedResult: Result<CommunicatorResponse<TestMessage>, Error>?
        communicator.performRequest(to: TestEndpoint()) { result in
            expectedResult = result
            communicatorCompletionExpectation.fulfill()
        }

        wait(for: [communicatorCompletionExpectation], timeout: 1.0)

        switch expectedResult {
        case .success(let response)?:
            XCTFail("Unexpectedly found response when testing for error handling: \(response)")

        case .failure(let error)?:
            guard let communicatorError = error as? CommunicatorError,
                case .unacceptableStatusCode(let communicatorErrorReason) = communicatorError
                else {
                    XCTFail("Expected received error to be a CommunicatorError.unacceptableStatusCode")
                    return
            }

            XCTAssertEqual(communicatorErrorReason, CommunicatorError.ErrorReason.clientError(code: 401, data: Data()))

        case .none:
            XCTFail("Expected expectedResult to be non-optional")
        }
    }
}

//
//  APICommunicatorTests.swift
//  EndpointsTests
//
//  Created by Simon Jarbrant on 2019-06-17.
//

import XCTest
import EndpointTesting

@testable import Endpoints

private struct TestData: Decodable {
    let message: String
}

private struct TestEndpoint: Endpoint {
    var baseURL: URL = URL(string: "https://example.com")!
    var path: String = "/"
    var method: HTTPMethod = .get

    var unpacker: JSONUnpacker<TestData> = JSONUnpacker(decoder: JSONDecoder())
}

class APICommunicatorTests: XCTestCase {
    func testDecodesJSON() {
        let response = TestTransporter.TestResponse(code: 200, data: TestFixtures.simpleMessageData)
        let testTransporter = TestTransporter(responses: [response])
        let communicator = APICommunicator(transport: testTransporter)

        let expectation = XCTestExpectation(description: "Communicator response expectation")

        let endpoint = TestEndpoint()
        communicator.performRequest(to: endpoint) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.body.message, "Hi!")
            case .failure(let error):
                XCTFail("APICommunicator unexpectedly returned failure response: \(error)")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFailsWhenUnauthorized() {
        let response = TestTransporter.TestResponse(code: 401, data: Data(capacity: 0))
        let testTransporter = TestTransporter(responses: [response])
        let communicator = APICommunicator(transport: testTransporter)

        let expectation = XCTestExpectation(description: "Communicator response expectation")

        let endpoint = TestEndpoint()
        communicator.performRequest(to: endpoint) { result in
            switch result {
            case .success:
                XCTFail("APICommunicator unexpectedly returned success response")
            case .failure(let error):
                if case CommunicatorError.unacceptableStatusCode(let reason) = error,
                    case .clientError(code: let code, _) = reason {

                    XCTAssertEqual(code, 401)
                } else {
                    XCTFail("Got unexpected error from APICommunicator: \(error)")
                }
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

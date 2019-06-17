//
//  EndpointTests.swift
//  EndpointsTests
//
//  Created by Simon Jarbrant on 2019-06-17.
//

import XCTest

@testable import Endpoints

private struct TestEndpoint: Endpoint {
    var baseURL: URL = URL(string: "https://example.com")!
    var path: String = "/"
    var queryItems: [URLQueryItem] = []
    var method: HTTPMethod = .get
}

class EndpointTests: XCTestCase {
    func testCreatesValidURL() throws {
        let endpoint = TestEndpoint()
        let request = try endpoint.asURLRequest()

        XCTAssertEqual(request.url?.absoluteString, "https://example.com/")
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func testAppliesURLQueryItems() throws {
        var endpoint = TestEndpoint()
        endpoint.queryItems = [
            URLQueryItem(name: "first", value: "firstValue"),
            URLQueryItem(name: "second", value: "secondValue")
        ]

        let request = try endpoint.asURLRequest()

        XCTAssertEqual(request.url?.absoluteString, "https://example.com/?first=firstValue&second=secondValue")
    }
}

//
//  TestEndpoint.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-10-29.
//

import Foundation

@testable import Endpoints

struct TestEndpoint: Endpoint {
    typealias ResponseType = TestMessage

    var baseURL: URL = URL(string: "https://example.com")!
    var path: String = "message"
    var method: HTTPMethod = .get
}

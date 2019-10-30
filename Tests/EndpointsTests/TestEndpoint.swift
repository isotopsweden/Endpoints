//
//  TestEndpoint.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-10-29.
//

import Foundation

@testable import Endpoints

struct TestEndpoint: Endpoint {
    var baseURL: URL = URL(string: "https://example.com")!
    var path: String = "message"
    var method: HTTPMethod = .get
    var unpacker: JSONUnpacker<TestMessage> = JSONUnpacker(decoder: JSONDecoder())
}

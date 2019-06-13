//
//  CommunicatorResponse.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-06-13.
//

import Foundation

public struct CommunicatorResponse<Body> {
    public let headers: [AnyHashable: Any]
    public let code: Int
    public let body: Body

    public init(headers: [AnyHashable: Any] = [:], code: Int, body: Body) {
        self.headers = headers
        self.code = code
        self.body = body
    }
}

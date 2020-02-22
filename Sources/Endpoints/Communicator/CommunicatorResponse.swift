//
//  CommunicatorResponse.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-06-13.
//

import Foundation

public struct CommunicatorResponse<Body> {
    public let body: Body
    public let code: Int
    public let headers: [AnyHashable: Any]

    public init(body: Body, code: Int, headers: [AnyHashable: Any] = [:]) {
        self.body = body
        self.code = code
        self.headers = headers
    }
}

public extension CommunicatorResponse where Body == Void {
    init(code: Int, headers: [AnyHashable: Any] = [:]) {
        self.body = ()
        self.code = code
        self.headers = headers
    }
}

//
//  TransportationResult.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-06-13.
//

import Foundation

public struct TransportationResult {
    public let response: HTTPURLResponse
    public let data: Data

    public init(response: HTTPURLResponse, data: Data) {
        self.response = response
        self.data = data
    }
}

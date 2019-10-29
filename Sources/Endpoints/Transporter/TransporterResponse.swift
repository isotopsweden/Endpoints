//
//  TransporterResponse.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-06-13.
//

import Foundation

public struct TransporterResponse {
    public let urlResponse: HTTPURLResponse
    public let data: Data

    public init(response: HTTPURLResponse, data: Data) {
        self.urlResponse = response
        self.data = data
    }
}

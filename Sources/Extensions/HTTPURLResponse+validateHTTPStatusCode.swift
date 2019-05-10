//
//  HTTPURLResponse+validateHTTPStatusCode.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-12-23.
//

import Foundation

extension HTTPURLResponse {
    static var successfulStatusCode: Range<Int> {
        return 200..<300
    }
}

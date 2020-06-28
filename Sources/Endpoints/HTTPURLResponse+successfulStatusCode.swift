//
//  HTTPURLResponse+successfulStatusCode.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2020-06-28.
//

import Foundation

extension HTTPURLResponse {
    static var successfulStatusCode: Range<Int> {
        return 200..<300
    }
}

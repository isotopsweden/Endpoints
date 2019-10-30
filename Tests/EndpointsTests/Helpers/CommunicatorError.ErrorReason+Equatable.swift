//
//  CommunicatorError.ErrorReason+Equatable.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-10-29.
//

import Foundation

@testable import Endpoints

extension CommunicatorError.ErrorReason: Equatable {
    public static func == (lhs: CommunicatorError.ErrorReason, rhs: CommunicatorError.ErrorReason) -> Bool {
        switch (lhs, rhs) {
        case (.clientError(let lhsCode, let lhsData), .clientError(code: let rhsCode, data: let rhsData)):
            return lhsCode == rhsCode && lhsData == rhsData

        case (.serverError(let lhsCode), .serverError(code: let rhsCode)):
            return lhsCode == rhsCode

        default:
            return false
        }
    }
}

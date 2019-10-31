//
//  XCTestCase+assertResult.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-10-31.
//

import Foundation
import XCTest

extension XCTestCase {
    func assertSuccess<Success, Failure: Error>(
        _ result: Result<Success, Failure>?,
        predicate: (Success) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch result {
        case .success(let value)?:
            predicate(value)
        case .failure(let error)?:
            XCTFail("Result expected to be .success was .failure: \(error)", file: file, line: line)
        case .none:
            XCTFail("Expected result to be non-optional", file: file, line: line)
        }
    }

    func assertFailure<Success, Failure: Error>(
        _ result: Result<Success, Failure>?,
        predicate: (Failure) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch result {
        case .success?:
            XCTFail("Result expected to be .failure was .success", file: file, line: line)
        case .failure(let error)?:
            predicate(error)
        case .none:
            XCTFail("Expected result to be non-optional", file: file, line: line)
        }
    }
}

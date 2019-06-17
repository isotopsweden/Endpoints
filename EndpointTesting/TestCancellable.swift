//
//  TestCancellable.swift
//  EndpointTesting iOS
//
//  Created by Simon Jarbrant on 2019-06-17.
//

import Foundation
import Endpoints

public class TestCancellable: Cancellable {
    public private(set) var cancelled = false

    public func cancel() {
        cancelled = true
    }
}

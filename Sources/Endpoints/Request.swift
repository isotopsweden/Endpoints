//
//  Request.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2020-06-28.
//

import Foundation

public struct Request {
    private let _cancel: () -> Void

    public init(cancel: @escaping () -> Void) {
        self._cancel = cancel
    }

    func cancel() {
        _cancel()
    }
}

// MARK: - Convenience init with a URLSessionDataTask
public extension Request {
    init(dataTask: URLSessionDataTask) {
        self.init {
            dataTask.cancel()
        }
    }
}

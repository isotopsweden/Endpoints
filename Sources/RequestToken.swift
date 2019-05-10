//
//  RequestToken.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2018-12-05.
//

import Foundation

public protocol RequestToken {
    func cancel()
}

class URLSessionRequestToken: RequestToken {
    private weak var task: URLSessionTask?

    init(task: URLSessionTask) {
        self.task = task
    }

    func cancel() {
        task?.cancel()
    }
}

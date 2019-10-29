//
//  Transporter.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-05-25.
//

import Foundation

public protocol Transporter {
    func send(_ request: URLRequest, completionHandler: @escaping (Result<TransportationResult, CommunicatorError>) -> Void) -> Cancellable
}

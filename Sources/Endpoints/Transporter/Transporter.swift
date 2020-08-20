//
//  Transporter.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-05-25.
//

import Foundation

public protocol Transporter {
    /// Sends the given `URLRequest` using this `Transporter` and calls `completionHandler` upon completion.
    ///
    /// Note: It is expected that this function returns `.success` if the server responds, regardless of the HTTP
    /// status code returned by the server. This matches the behavior of `URLSession.dataTask`.
    ///
    /// - Parameters:
    ///   - request: an instance of `URLRequest` describing the request.
    ///   - completionHandler: called upon completion with either `.success` or `.failure` depending on outcome.
    ///
    /// - Returns:
    ///   - `Request` token used for cancelling or inspecting the request.
    func send(
        _ request: URLRequest,
        completionHandler: @escaping (Result<TransporterResponse, CommunicatorError>) -> Void
    ) -> Request
}

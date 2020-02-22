//
//  CommunicatorError.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2019-10-29.
//

import Foundation

public enum CommunicatorError<ErrorResponse>: Error {
    /// An error indicating that the `Endpoint`'s URL is invalid.
    case invalidURL

    /// An error indicating that something went wrong when encoding the contents of the `Endpoint`'s `DataPacker`.
    case packingError(underlyingError: Error)

    /// An error indicating that something went wrong when sending the request through the network.
    case networkError(underlyingError: Error)

    /// An error indicating that the `Endpoint`'s `DataPacker.DataType` could not be decoded.
    case unpackingError(underlyingError: Error)

    /// An error indicating that an unacceptable HTTP response code (not 200 - 300) was received from the server. More information
    /// can be found in the associated `ErrorReason`.
    case unacceptableStatusCode(ErrorReason)

    /// An error indicating the an unknown and unsupported response was received from the server.
    case unsupportedResponse

    public enum ErrorReason {
        /// The HTTP response code received from the server likely is a client error. In practice this means HTTP 400 - 499.
        /// If the server included response data, that is included in the associated `response` value.
        case clientError(code: Int, response: ErrorResponse)

        /// The HTTP response code received from the server likely is a server error. In practice this means HTTP 500-ish codes.
        case serverError(code: Int)
    }
}

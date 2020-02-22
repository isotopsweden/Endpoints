//
//  TransporterError.swift
//  EndpointsTests iOS
//
//  Created by Simon Jarbrant on 2020-02-22.
//

import Foundation

public enum TransporterError: Error {
    case networkError(underlyingError: Error)
    case unsupportedResponse
}

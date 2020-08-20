//
//  Request+Cancellable.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2020-08-20.
//

#if canImport(Combine)
import Combine

@available(iOS 13.0, OSX 10.15, *)
extension Request: Cancellable {}
#endif

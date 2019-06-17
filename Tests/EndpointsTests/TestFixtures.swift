//
//  TestFixtures.swift
//  EndpointsTests
//
//  Created by Simon Jarbrant on 2019-06-17.
//

import Foundation

struct TestFixtures {
    static var simpleMessageData: Data {
        let message = """
{
    "message": "Hi!"
}
"""
        return message.data(using: .utf8)!
    }
}

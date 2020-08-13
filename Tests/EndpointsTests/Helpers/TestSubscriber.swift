//
//  TestSubscriber.swift
//  
//
//  Created by Simon Jarbrant on 2020-08-13.
//

#if canImport(Combine)
import Combine

@testable import Endpoints

@available(iOS 13.0, OSX 10.15, *)
class TestSubscriber<DataType>: Combine.Subscriber {
    typealias Input = CommunicatorResponse<DataType>
    typealias Failure = CommunicatorError

    var subscription: Subscription?
    var onCompletion: (Subscribers.Completion<CommunicatorError>) -> Void = { _ in }

    func receive(subscription: Subscription) {
        self.subscription = subscription
    }

    func receive(_ input: CommunicatorResponse<DataType>) -> Subscribers.Demand {
        return .none
    }

    func receive(completion: Subscribers.Completion<CommunicatorError>) {
        onCompletion(completion)
    }

    func requestData() {
        subscription?.request(.unlimited)
    }
}
#endif

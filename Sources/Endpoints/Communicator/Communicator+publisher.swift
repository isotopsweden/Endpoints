//
//  Communicator+publisher.swift
//  Endpoints
//
//  Created by Simon Jarbrant on 2020-07-16.
//

#if canImport(Combine)
import Combine

@available(iOS 13.0, OSX 10.15, *)
public extension Communicator {
    func publisher<E: Endpoint>(
        for endpoint: E
    ) -> AnyPublisher<CommunicatorResponse<E.ResponseType>, CommunicatorError> {
        return EndpointsRequestPublisher(communicator: self, endpoint: endpoint)
            .eraseToAnyPublisher()
    }
}

// MARK: - Publisher
@available(iOS 13.0, OSX 10.15, *)
public struct EndpointsRequestPublisher<E: Endpoint>: Publisher {
    public typealias Output = CommunicatorResponse<E.ResponseType>
    public typealias Failure = CommunicatorError

    public let communicator: Communicator
    public let endpoint: E

    public init(communicator: Communicator, endpoint: E) {
        self.communicator = communicator
        self.endpoint = endpoint
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(
            subscriber: subscriber,
            communicator: communicator,
            endpoint: endpoint)

        subscriber.receive(subscription: subscription)
    }
}

// MARK: - Subscription
@available(iOS 13.0, OSX 10.15, *)
extension EndpointsRequestPublisher {
    final class Subscription<Subscriber: Combine.Subscriber>: Combine.Subscription
    where Subscriber.Input == CommunicatorResponse<E.ResponseType>, Subscriber.Failure == CommunicatorError {

        private var subscriber: Subscriber?
        private let communicator: Communicator
        private let endpoint: E

        private var request: Request?

        init(subscriber: Subscriber, communicator: Communicator, endpoint: E) {
            self.subscriber = subscriber
            self.communicator = communicator
            self.endpoint = endpoint
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0, request == nil else {
                return
            }

            // Retain a strong reference to the subscriber here, to be used in the
            // performRequest completion block below.
            guard let subscriber = subscriber else {
                return
            }

            // Releasing this reference ensures that the subscriber is only referenced by the
            // completion block below, which avoids memory leaks.
            self.subscriber = nil

            request = communicator.performRequest(to: endpoint) { result in
                switch result {
                case .success(let response):
                    _ = subscriber.receive(response) // We don't care about any additional demand
                    subscriber.receive(completion: .finished)
                case .failure(let error):
                    subscriber.receive(completion: .failure(error))
                }
            }
        }

        func cancel() {
            request?.cancel()
            subscriber = nil
        }
    }
}
#endif

# Endpoints
[![Build Status](https://github.com/isotopsweden/Endpoints/workflows/CI/badge.svg)](https://github.com/isotopsweden/Endpoints/actions)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

Endpoints is a thin network abstraction layer on top of `URLSession`, that enables you to get up and running with your networking code in seconds:

```swift
import Endpoints

struct MyEndpoint: Endpoint {
    let baseURL: URL = URL(string: "https://mysite.com/api")!
    let path: String = "/"
    let method: HTTPMethod = .get
}

let endpoint = MyEndpoint()
let communicator = Communicator()
communicator.performRequest(to: endpoint) { result in
    switch result {
    case .success(let response):
        // Yay!
        break
    case .failure(let error):
        // Nay...
        break
    }
}
```

## Usage

In many cases, you'd probably be interested in the actual response data from your request. Endpoints makes 
decoding Swift `struct`s simple, using the associated `ResponseType` type:

```swift
// Define your model
struct MyModel: Decodable {
    let id: Int
    let name: String
}

struct MyEndpoint: Endpoint {
    // Declare a ResponseType in your endpoint
    typealias ResponseType = MyModel

    let baseURL: URL = URL(string: "https://mysite.com/api")!
    let path: String = "/mymodel/1"
    let method: HTTPMethod = .get
}

communicator.performRequest(to: endpoint) { result in
    switch result {
    case .success(let response):
        // response.body contains an instance of MyModel
        break
    case .failure(let error):
        break
    }
}
```

By default, Endpoints assumes JSON decoding. If you need to change the default decoding behavior, have a look at
the "Customization through extensions" section.

#### Combine
Endpoints also comes with built-in support for Apple's Combine framework:

```swift
communicator.publisher(for: endpoint)
    .sink(
        receiveCompletion: { completion in
            // Handle successful completion or failure
        },
        receiveValue: { response in
            // Handle a successful response here
        }
    )
```

### Customization through extensions
If you need to change the default decoding behavior of your endpoints, you can simply override the default 
implementation:

```swift
extension Endpoint where ResponseType: Decodable {
    func unpack(data: Data) throws -> ResponseType {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(ResponseType.self, from: data)
    }
}
```

If you want to mix and match, you can leave the default as it is and override the `unpack(data:)` function in your 
Endpoint implementations to provide custom decoding there:

```swift
struct MyEndpoint: Endpoint {
    typealias ResponseType = MyModel

    let baseURL: URL = URL(string: "https://mysite.com/api")!
    let path: String = "/mymodel/1"
    let method: HTTPMethod = .get

    func unpack(data: Data) throws -> MyModel {
        let decoder = JSONDecoder.myDecoder
        return try decoder.decode(MyModel.self, from: data)
    }
}
```

#### Common extensions
In many cases you want to use a single `baseURL` for all your endpoints, which you can enable by extending the
`Endpoint` protocol:

```swift
extension Endpoint {
    var baseURL: URL {
        return URL(string: "https://mysite.com/api")!
    }
}
```

### Transporters
The `Communicator` class relies on the `Transporter` protocol to do the heavy lifting. This is a simple procotol 
containing a single function:

```swift
public protocol Transporter {
    func send(
        _ request: URLRequest, 
        completionHandler: @escaping (Result<TransportationResult, CommunicatorError>) -> Void
    ) -> Request
}
```

By default, Endpoints extends `URLSession` to conform to this protocol and then uses it to perform the actual 
network requests. This allows you to create your own custom `Transporter`s, for example for authentication:

```swift
class AuthorizationTransporter: Transporter {
    private let base: Transporter
    private let authenticationDetails: String

    init(base: Transporter, authenticationDetails: String) {
        self.base = base
        self.authenticationDetails = authenticationDetails
    }

    func send(
        _ request: URLRequest, 
        completionHandler: @escaping (Result<TransportationResult, CommunicatorError>) -> Void
    ) -> Request {
        var modifiedRequest = request
        modifiedRequest.addValue("Basic \(authenticationDetails)", forHTTPHeaderField: "Authorization")

        return base.send(modifiedRequest, completionHandler: completionHandler)
    }
}

let authTransporter = AuthorizationTransporter(base: URLSession.shared, authenticationDetails: "...")
let communicator = Communicator(transporter: authTransporter)
```

### Testing
You are likely to want to test your code that is built on top of Endpoints. To assist you with this, Endpoints includes the 
EndpointsTesting package that provides you with helpful classes when testing. Below is a sample snippet of its usage:

```swift
import EndpointsTesting

class MyTestCase: XCTestCase {
    func testMyCode() {
        // The TestTransporter class can enqueue responses, that are responded with in FIFO-order
        // (first-in first-out). This allows you to set up a chain of responses.
        let testTransporter = TestTransporter(responses: [
            .success(.init(code: 200, data: MyTestFixture.sampleData))
        ])

        // When setting up the Communicator, simply pass in the TestTransporter
        let communicator = Communicator(transporter: testTransporter)

        // Done! Here you would typically put your test code
    }
}
```

## Installation
To get started using Endpoints, simply add it as a Swift Package dependency: 

```
.package(url: "https://github.com/isotopsweden/Endpoints", from: "3.0.0")
```

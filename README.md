# Endpoints
[![Build status](https://build.appcenter.ms/v0.1/apps/ee9e4d79-32a9-4792-8de5-ef5b746d078d/branches/master/badge)](https://appcenter.ms)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
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
let communicator: Communicator = APICommunicator()
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

In many cases, you'd probably be interested in the actual response data from your request. Endpoints makes decoding Swift `struct`s simple, using the `DataUnpacker` protocol and the `JSONUnpacker` type:

```swift
// Define your model
struct MyModel: Decodable {
    let id: Int
    let name: String
}

struct MyEndpoint: Endpoint {
    let baseURL: URL = URL(string: "https://mysite.com/api")!
    let path: String = "/mymodel/1"
    let method: HTTPMethod = .get

    // Declare a DataUnpacker in your endpoint
    let unpacker: JSONUnpacker = JSONUnpacker<MyModel>(decoder: JSONDecoder())
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

If you need to unpack other types of data, have a look at the `DataUnpacker` protocol.

### Customization through extensions
In the above example, we use a plain `JSONDecoder` without any custom decoding options set. However, you may want to customize this. A good approach is to use extensions:

```swift
extension JSONDecoder {
    static var myDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }
}
```

Then, to use it in your endpoint:

```swift
struct MyEndpoint: Endpoint {
    let baseURL: URL = URL(string: "https://mysite.com/api")!
    let path: String = "/mymodel/1"
    let method: HTTPMethod = .get

    let unpacker: JSONUnpacker = JSONUnpacker<MyModel>(decoder: .myDecoder)
}
```

If you want to use your `.myDecoder` in multiple endpoints, it might be a good idea to extend the JSONUnpacker type with a convenience initializer:

```swift
extension JSONUnpacker {
    init() {
        self.init(decoder: .myDecoder)
    }
}

struct MyEndpoint: Endpoint {
    let baseURL: URL = URL(string: "https://mysite.com/api")!
    let path: String = "/mymodel/1"
    let method: HTTPMethod = .get

    let unpacker: JSONUnpacker = JSONUnpacker<MyModel>()
}
```

#### Common extensions
In many cases you want to use a single `baseURL` for all your endpoints, which you can enable by extending the `Endpoint` protocol:

```swift
extension Endpoint {
    var baseURL: URL {
        return URL(string: "https://mysite.com/api")!
    }
}
```

### Transporters
The `APICommunicator` class relies on the `Transporter` protocol to do the heavy lifting. This is a simple procotol containing a single function:

```swift
public protocol Transporter {
    func send(_ request: URLRequest, completionHandler: @escaping (Result<TransportationResult, Error>) -> Void) -> Cancellable
}
```

By default, Endpoints extends `URLSession` to conform to this protocol and then uses it to perform the actual network requests. This allows you to create your own custom `Transporter`s, for example for authentication:

```swift
class AuthorizationTransporter: Transporter {
    private let base: Transporter
    private let authenticationDetails: String

    init(base: Transporter, authenticationDetails: String) {
        self.base = base
        self.authenticationDetails = authenticationDetails
    }

    func send(_ request: URLRequest, completionHandler: @escaping (Result<TransportationResult, Error>) -> Void) -> Cancellable {
        var modifiedRequest = request
        modifiedRequest.addValue("Basic \(authenticationDetails)", forHTTPHeaderField: "Authorization")

        return base.send(modifiedRequest, completionHandler: completionHandler)
    }
}

let authTransporter = AuthorizationTransporter(base: URLSession.shared, authenticationDetails: "...")
let communicator = APICommunicator(transport: authTransporter)
```

## Installation
The preferred way of installation is through [Swift Package Manager](https://github.com/apple/swift-package-manager). If you're using Xcode 11, you can add Endpoints as a dependency by simply clicking `File -> Swift Packages -> Add Package Dependency...`. You can also add it manually to your `Package.swift` file:

```
.package(url: "https://github.com/isotopsweden/Endpoints", from: "1.0.0")
```

Installation through [Carthage](https://github.com/Carthage/Carthage) is also supported:

```
github "isotopsweden/Endpoints" ~> 1.0.0
```

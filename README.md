# Endpoints
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Usage
To get started with Endpoints, begin by defining an instance of the `Endpoint` protocol:

```swift
import Endpoints

struct MyEndpoint: Endpoint {
    // JSONUnpacker is included by default, but you can create your own DataUnpacker instance if necessary
    typealias Unpacker = JSONUnpacker<MyDecodable>

    let baseURL: URL = URL(string: "https://example.com/api")!
    let path: String = "/v1/test"
    let queryItems: [URLQueryItem] = []
    let method: HTTPMethod = .get
}
```

Then, simply pass it to a `Communicator` instance to perform the network request. By default, the framework includes the `APICommunicator` class that you can use for most requests:

```swift
import Endpoints

let endpoint = MyEndpoint()

let communicator = APICommunicator()
communicator.performRequest(to: endpoint) { result in
    switch result {
    case .success(let response):
        // response.body contains an instance of MyDecodable from the request
        break
    case .failure(let error):
        break
    }
}
```


## Installation
The preferred way of installation is through [Carthage](https://github.com/Carthage/Carthage):

```
git "ssh://git@github.com:isotopsweden/Endpoints.git" "master"
```

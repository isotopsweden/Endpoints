# Endpoints
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

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

## Installation
The preferred way of installation is through [Carthage](https://github.com/Carthage/Carthage):

```
github "isotopsweden/Endpoints" "master"
```

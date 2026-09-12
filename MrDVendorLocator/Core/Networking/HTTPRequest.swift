import Foundation

struct HTTPRequest: Equatable {
    let method: HTTPMethod
    let path: String
    var headers: [String: String]

    final class Builder {
        private var method: HTTPMethod = .get
        private var path = "/"
        private var headers: [String: String] = ["Accept": "application/json"]

        func method(_ method: HTTPMethod) -> Builder {
            self.method = method
            return self
        }

        func path(_ path: String) -> Builder {
            self.path = path
            return self
        }

        func header(_ name: String, _ value: String) -> Builder {
            headers[name] = value
            return self
        }

        func build() -> HTTPRequest {
            HTTPRequest(method: method, path: path, headers: headers)
        }
    }
}

extension HTTPRequest {
    static var vendors: HTTPRequest {
        Builder()
            .method(.get)
            .path("/v1/vendors")
            .build()
    }

    static var session: HTTPRequest {
        Builder()
            .method(.get)
            .path("/v1/session")
            .build()
    }
}

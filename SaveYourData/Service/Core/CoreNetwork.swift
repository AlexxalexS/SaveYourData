import Foundation
import Combine
import KeychainSwift

/*

## Base URL

    NetworkService.baseUrl is used as domain for requests
    APIPath is used as endPoint

    Example:

        NetworkService.baseUrl = "example.com/"

        extension APIPath {

            case endPoint

            var endPoint: String {
                switch self {
                case .endPoint:
                    return "endPoint"
                }
            }

        }

    Result:

        "example.com/endPoint"


 ## API PATH

     The APIPath structure is used to indicate the endpoint.
     The endpoint parameter is used to define the link string.
     If you want to add parameters inside the link, then pass it in the case parameter.
     To use it, you need to expand the enum and register the necessary cases.

        Example:

            extension APIPath {

                case sampleEndPoint
                case endPointWithParam(id: String)

                var endPoint: String {
                    switch self {
                    case .sampleEndPoint:
                        return "example"
                    case .endPointWithParam(let id):
                        return "example/\(id)"
                    }
                }

            }

 ## REQUEST

    If you need a request without parameters, then use the function

            static func request<T: Codable>(
                _ path: APIPath,
                _ method: MethodREST
            )

        Example:

            request(.endPoint, .get)

    If you need to pass bodyParameters, then create a structure identical
    to the request body and inherit from the RequestEncodableProtocol protocol.
    Use the function to query:

            static func request<T: Codable>(
                _ path: APIPath,
                _ method: MethodREST,
                _ bodyParameters: RequestEncodableProtocol? = nil
            )

        Example:

            struct RequestBody: RequestEncodableProtocol {

                let field: String

            }

            let body = RequestBody(field: "example")
            request(.endPoint, .post, body)


    If you need to pass bodyParameters, then use the function to query:

            static func request<T: Codable>(
                _ path: APIPath,
                _ method: MethodREST,
                _ urlParameters: [URLQueryItem]? = nil
            ) -> AnyPublisher<T, Error> {
                request(path, method, urlParameters, nil)
            }

        Example:

            request(.endPoint, .get, [.init(name: "name", value: "value")])

 ## isLoggedRequest

    isLoggedRequest is used as a toggler for logging.
    If you do not want to receive logs to the console, you can turn it off :)

    P.S. The request is logged after the response from the server

 */

private var isLoggedRequest = true

enum NetworkError: Error {

    case encodingFailed

}

private struct APIClient {

    struct Response<T> {

        let value: T
        let response: URLResponse

    }

    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
        URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                if isLoggedRequest {
                    NetworkLogger.log(request: request, result: result)
                }
                let value = try JSONDecoder().decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .mapError {
                switch $0 {
                case DecodingError.dataCorrupted(let context):
                    print(context)
                case DecodingError.keyNotFound(let key, let context):
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                case DecodingError.valueNotFound(let value, let context):
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                case DecodingError.typeMismatch(let type, let context):
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                default:
                    break
                }
                print(T.self)
                return $0
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}

enum NetworkService {

    fileprivate static let apiClient = APIClient()
    fileprivate static let baseUrl = URL(string: "\(APIServiceEnvironment.rawValue)/")!

}

enum MethodREST: String {

    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"

}

var accessToken: String? = KeychainSwift().get(.token)
var secret: String? = KeychainSwift().get(.secret)

extension NetworkService {

    private static var tasks: [AnyCancellable?] = []

    static func request<T: Codable>(
        _ path: APIPath,
        _ method: MethodREST
    ) -> AnyPublisher<T, Error> {
        request(path, method, nil, nil)
    }

    static func request<T: Codable>(
        _ path: APIPath,
        _ method: MethodREST,
        _ bodyParameters: RequestEncodableProtocol? = nil
    ) -> AnyPublisher<T, Error> {
        request(path, method, nil, bodyParameters)
    }

    static func request<T: Codable>(
        _ path: APIPath,
        _ method: MethodREST,
        _ urlParameters: [URLQueryItem]? = nil
    ) -> AnyPublisher<T, Error> {
        request(path, method, urlParameters, nil)
    }

    static func request<T: Codable>(
        _ path: APIPath,
        _ method: MethodREST,
        _ urlParameters: [URLQueryItem]?,
        _ bodyParameters: RequestEncodableProtocol?
    ) -> AnyPublisher<T, Error> {
        guard
            var components = URLComponents(
                url: baseUrl.appendingPathComponent(path.endPoint),
                resolvingAgainstBaseURL: true
            )
        else {
            fatalError("Couldn't create URLComponents")
        }

        components.queryItems = urlParameters

        guard let url = components.url else {
            fatalError("Couldn't create URL")
        }

        var request = URLRequest(url: url)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = bodyParameters?.toJSONData()

        request.httpMethod = method.rawValue

        let publisher: AnyPublisher<T, Error> = apiClient.run(request)
            .map(\.value)
            .eraseToAnyPublisher()

        return publisher.map {
            if let result = $0 as? DefaultResponse<LoginResponse> {
                if let accessToken = result.data?.accessToken {
                    KeychainSwift().set(accessToken, forKey: .token)
                } else {
                    KeychainSwift().delete(.token)
                }
                accessToken = result.data?.accessToken

                if let secret = result.data?.secret {
                    KeychainSwift().set(secret, forKey: .secret)
                } else {
                    KeychainSwift().delete(.secret)
                }
            }
            return $0
        }.eraseToAnyPublisher()
    }

    static func cancelAllTasks() {
        tasks.forEach {
            $0?.cancel()
        }
        tasks = []
    }

}

protocol RequestEncodableProtocol: Encodable {

    func toJSONData() -> Data?

}

extension RequestEncodableProtocol {

    func toJSONData() -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(self)
    }

}

class NetworkLogger {

    static func log(request: URLRequest, result: URLSession.DataTaskPublisher.Output? = nil) {
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }

        let urlAsString: String = request.url?.absoluteString ?? .empty
        let urlComponents = NSURLComponents(string: urlAsString)

        let method = request.httpMethod != nil ? "\(request.httpMethod ?? .empty)" : .empty
        let path = "\(urlComponents?.path ?? String.empty)"
        let query = "\(urlComponents?.query ?? String.empty)"
        let host = "\(urlComponents?.host ?? String.empty)"

        var logOutput =
            """
            \(urlAsString) \n\n
            \(method) \(path)?\(query) HTTP/1.1 \n
            HOST: \(host)\n
            """

        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }

        if let body = request.httpBody {
            logOutput +=
                """
                \n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? NSString(string: String.empty))
                """
        }

        if let cookies = readCookie(forURL: request.url) {
            logOutput += "\n \(cookies)"
        }

        logOutput +=
            """
            \n\nRESPONSE:
            \(String(describing: (result?.response as? HTTPURLResponse)?.statusCode))
            """

        try? logOutput +=
            """
            \(JSONSerialization.jsonObject(with: result?.data ?? Data(), options: []))
            """

        print(logOutput)
    }

    static func readCookie(forURL url: URL?) -> [HTTPCookie]? {
        guard let url = url else { return nil }
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: url) ?? nil
        return cookies
    }

}

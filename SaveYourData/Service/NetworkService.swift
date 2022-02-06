import Combine


enum APIPath {

    case apiAuthLogin

    var endPoint: String {
        switch self {
        case .apiAuthLogin:
            return "api/auth/login"
        }
    }

}

extension NetworkService {

    // MARK: Login

    struct LoginRequest: RequestEncodableProtocol {

        let username: String
        let password: String

    }

    static func login(_ body: LoginRequest) -> AnyPublisher<DefaultResponse<LoginResponse>, Error> {
        request(.apiAuthLogin, .post, body)
    }


}

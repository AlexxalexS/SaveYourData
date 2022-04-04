import Combine

enum APIPath {

    case apiAuthLogin
    case apiTotpGenerate

    var endPoint: String {
        switch self {
        case .apiAuthLogin:
            return "api/auth/login"
        case .apiTotpGenerate:
            return "api/totp/generate"
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

    // MARK: TOTP Generator
    struct TOTPRequest: RequestEncodableProtocol {

        let secret: String

    }

    static func totpGenerate(_ body: TOTPRequest) -> AnyPublisher<DefaultResponse<TOTPResponse>, Error> {
        request(.apiTotpGenerate, .post, body)
    }

}

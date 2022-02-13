let APIServiceEnvironment: APIEnvironment = .server

enum APIEnvironment: String {

    case local = "http://localhost:8080"
    case server = "https://new-server-totp.herokuapp.com"

}

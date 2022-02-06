let APIServiceEnvironment: APIEnvironment = .local

enum APIEnvironment: String {

    case local = "http://localhost:8080"
    case server = ""

}

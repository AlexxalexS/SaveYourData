struct LoginResponse: Codable {

    let id: String
    let email: String
    let accessToken: String
    let roles: [String]
    let secret: String
    let username: String

}

struct LoginResponse: Codable {

    let username: String
    let accessToken: String
    let roles: [String]
    let secret: String

}

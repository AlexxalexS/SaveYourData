struct DefaultResponse<T: Codable>: Codable {

    let code: Int?
    let data: T?
    let message: String?
    let error: [String: String]?

}

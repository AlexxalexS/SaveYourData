import Foundation

struct TOTPResponse: Codable {

    let token: String
    let remaining: Int

}

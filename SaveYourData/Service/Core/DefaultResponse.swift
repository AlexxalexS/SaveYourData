/*
    The response from the server is boilerplate.
    Therefore, there is a DefaultResponse with a generic parameter for the data.

    {
        data: {
            {
                *anyObject*
            },{
                *anyObject*
            },
        }
    }
*/

struct DefaultResponse<T: Codable>: Codable {

    let code: Int?
    let data: T?
    let message: String?
    let errors: [String: [String]]?

}

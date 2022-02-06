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

    var code: Int?
    let data: T?
    let errors: [String: [String]]?

}

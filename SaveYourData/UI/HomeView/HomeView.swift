import LocalAuthentication
import SwiftUI

struct Answer: Codable {
    var token: String
    var remaining: Int
}

struct HomeView: View {

    @State private var isUnlock = false
    @State var token = ""
    @State var time = 0


    var body: some View {
        VStack {
            if isUnlock {
                Text("Вы вошли").padding()
                Spacer()
                Text("Привет, Алексей!").font(.title).padding()

                Text(token)

                VStack {
                    QRCodeView(code: token)
                }

                Button(action: {
                    getSecret()
                }, label: {
                    Text("Выслать повторно")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(26)
                        .padding(.top, 60)
                })

                Button(action: {
                    isUnlock = false
                }, label: {
                    Text("Выйти")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(26)
                })
                Spacer()

                
            } else {
                Text("Войти в аккаунт").padding()
                Button(action: {
                    authenticate()
                }, label: {
                    Text("Войти по FaceID")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(26)
                })
            }

        }.animation(.easeInOut(duration: 0.3))

        //.onAppear(perform: authenticate)
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "We need to unloack your data."

            //context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        isUnlock = true
                        getSecret()
                    } else {
                        // some problem
                    }
                }
            }
        } else {
            // no biometric
        }
    }

    func getSecret() {
        guard let url =  URL(string:"https://fierce-dawn-61172.herokuapp.com/totp-generate") else { return }
        let id = "MR4CGXLCIFKHSMCDIEQUKSCXLBKEE3D2"
        let body = "secret=\(id))"
        let finalBody = body.data(using: .utf8)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody

        URLSession.shared.dataTask(with: request){ (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = data else {
                return
            }

            let decoder = JSONDecoder()

            do {
                let decod = try decoder.decode(Answer.self, from: data)
                time = decod.remaining
                token = decod.token
            } catch {
                debugPrint("Parser error")
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

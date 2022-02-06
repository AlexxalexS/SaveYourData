import LocalAuthentication
import SwiftUI
import Combine

struct Answer: Codable {
    var token: String
    var remaining: Int
}

struct HomeView: View {

    @State private var isUnlock = false
    @State private var token = ""

    @State private var cancellable: AnyCancellable?
    @ObservedObject var stateManager = RootState.shared

    @State var userName = UserDefaults.standard.string(forKey: "userName")

    @State var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if isUnlock {
                Text("Вы вошли").padding()
                Spacer()

                Text("Привет \(userName ?? "")!").font(.title).padding()

                Text(token)

                VStack {
                    QRCodeView(code: token)
                }

                Text("\(timeRemaining)")
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                        if timeRemaining == 0 {
                            getSecret()
                        }
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
                Spacer()
                Text("Показать QR код")
                    .padding()
                Button(action: {
                    authenticate()
                }, label: {
                    Text("Войти по FaceID")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(26)
                })

                Spacer()

                Button(action: {
                    token = .empty
                    secret = .empty
                    stateManager.state = .auth
                }, label: {
                    Text("Сменить аккаунт")
                })
            }

        }.animation(.easeInOut(duration: 0.3))
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
        guard let secret = secret else { return }
        cancellable = NetworkService.totpGenerate(.init(secret: secret)).sink(
            receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    print(error)
                default:
                    break
                }
        }, receiveValue: {
            guard $0.errors == nil else {
                return
            }
            if let isToken = $0.data?.token {
                token = isToken
            }
            if let isTime = $0.data?.remaining {
                timeRemaining = isTime
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        HomeView()
    }

}

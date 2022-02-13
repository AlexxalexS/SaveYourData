import LocalAuthentication
import SwiftUI
import Combine
import SwiftOTP
import KeychainSwift

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
                HStack{
                    Spacer()
                    Text("Вы вошли")
                    Spacer()
                }.overlay(
                    Button(action: {
                        isUnlock = false
                    }, label: {
                        Text("Выйти")
                            .padding(8)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(26)
                            .font(.caption)
                    }).padding(.horizontal), alignment: .trailing
                )

                Text("Привет \(userName ?? "")!")
                    .font(.title)
                    .padding()

                QRCodeView(code: "\(token).\(userId ?? "")")
                    .frame(height: 400)

                ZStack {
                    Circle()
                        .stroke(lineWidth: 25.0)
                        .foregroundColor(timeRemaining >= 5 ? Color.blue : Color.red)
                        .opacity(0.3)

                    Circle()
                        .trim(from: 0, to: CGFloat(Float(1.000/30.000) * Float(timeRemaining)))
                        .stroke(style: StrokeStyle(lineWidth: 25.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(timeRemaining >= 5 ? Color.blue : Color.red)
                        .rotationEffect(Angle(degrees: -90.0))
                        .onReceive(timer) { _ in
                            if timeRemaining > 0 {
                                timeRemaining -= 1
                            }
                            if timeRemaining == 0 {
                                generateSecret()
                            }
                        }
                }.padding()

                Button(action: {
                    generateSecret()
                }, label: {
                    Text("Сгенерировать заново")
                        .padding(8)
                        .font(.body)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(26)
                })
                    .padding(.top, 40)
            } else {
                Spacer()
                Text("Показать QR код")
                    .padding()

                Button(action: {
                    authenticate()
                }, label: {
                    Text("Войти по FaceID")
                        .padding()
                        .padding(.horizontal)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(26)
                })

                Spacer()

                Button(action: {
                    KeychainSwift().delete(.userId)
                    KeychainSwift().delete(.token)
                    KeychainSwift().delete(.secret)
                    stateManager.state = .auth
                }, label: {
                    Text("Сменить аккаунт")
                })
            }

        }.animation(.easeInOut(duration: 0.3))
            .onAppear {
                generateSecret()
            }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "We need to unlock your data."

            //context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        isUnlock = true
                        generateSecret()
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
                    cancellable = nil
                default:
                    break
                }
            }, receiveValue: {
                guard $0.error == nil else {
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

    func generateSecret() {
        guard let secret = secret else { return }
        guard let data = base32DecodeToData(secret) else { return }

        let totp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1)
        guard let code = totp?.generate(time: Date()) else { return }

        token = code

        updateTimer()
    }

    private func updateTimer() {
        let date = Date()
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: date)

        timeRemaining = Int(round(30 - ((Double(seconds))).truncatingRemainder(dividingBy: 30)))
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        HomeView()
    }

}

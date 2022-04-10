import LocalAuthentication
import SwiftUI

import SwiftOTP
import KeychainSwift

struct HomeView: View {

    @Environment(\.scenePhase) var scenePhase
    @State private var alert: AlertMessage?
    @State private var isUnlock = false
    @State private var token = ""
    @State var timeRemaining = 10

    var body: some View {
        VStack {
            if isUnlock {
                ViewIsUnlock(isUnlock: $isUnlock, token: $token, timeRemaining: $timeRemaining) {
                    generateSecret()
                }
            } else {
                ViewNotUnlock() {
                    authenticate()
                }
            }
        }.alert($alert)
            .animation(.easeInOut(duration: 0.3))
            .onAppear {
                generateSecret()
            }
            .onChange(of: scenePhase) {
                setupSceneState($0)
            }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Это нужно для возможности входа в приложение по лицу, и обеспечения безопасности."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlock = true
                        generateSecret()
                    } else {
                        alert = .init(title: "Ошибка", message: authenticationError?.localizedDescription ?? "")
                    }
                }
            }
        } else {
            alert = .init(title: "Ошибка", message: "В вашем устройстве нет FaceID")
        }
    }

    private func generateSecret() {
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

    private func setupSceneState(_ scene: ScenePhase) {
        switch scene {
        case .background, .inactive:
            isUnlock = false
        case .active:
            break
        @unknown default:
            break
        }
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        HomeView()
    }

}

private struct ViewNotUnlock: View {

    var action: () -> ()
    @ObservedObject var stateManager = RootState.shared

    var body: some View {
        Spacer()
        Text("Показать QR код")
            .padding()

        Button(action: {
            action()
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

}

private struct ViewIsUnlock:View {

    @Binding var isUnlock: Bool
    @Binding var token: String
    @Binding var timeRemaining: Int
    var action: () -> ()

    @State var userName = UserDefaults.standard.string(forKey: "userName")
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
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
                        self.action()
                    }
                }
        }.padding()

        Button(action: {
            action()
        }){
            Text("Сгенерировать заново")
                .padding(8)
                .font(.body)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(26)
        }.padding(.top, 40)
    }

}

import SwiftUI
import Combine

struct AuthView: View {

    @State private var cancellable: AnyCancellable?
    @ObservedObject var stateManager = RootState.shared

    @State var userName = ""
    @State var password = ""

    var body: some View {
        VStack {
            TextField("Имя пользователя", text: $userName)
            SecureField("Пароль", text: $password)

            Button(action: {
                login()
            }, label: {
                Text("Войти")
            })
        }.adjustContent()
    }

    private func login() {
        cancellable = NetworkService.login(.init(
            username: userName,
            password: password
        )).sink(
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

            if $0.code == 200 {
                stateManager.state = .home
            }
        })
    }

}

struct AuthView_Previews: PreviewProvider {

    static var previews: some View {
        AuthView()
    }

}

import SwiftUI
import Combine

struct AuthView: View {

    @State private var cancellable: AnyCancellable?
    @ObservedObject var stateManager = RootState.shared
    @ObservedObject var stateLoader = Loader.shared
    @State private var alert: AlertMessage?

    @State var userName = ""
    @State var password = ""

    @AppStorage("userName") private var username: String = .empty

    var body: some View {
        VStack {
            TextField("Имя пользователя", text: $userName)
                .font(Font.system(size: 14))
                .padding()
                .background(RoundedRectangle(cornerRadius: 50).fill(Color.gray.opacity(0.2)))
                .foregroundColor(.black)
                .padding(.bottom)
                .offset(x: 8, y: 10)

            SecureField("Пароль", text: $password)
                .font(Font.system(size: 14))
                .padding()
                .background(RoundedRectangle(cornerRadius: 50).fill(Color.gray.opacity(0.2)))
                .foregroundColor(.black)
                .padding(.bottom)
                .offset(x: 8, y: 10)

            Button(action: {
                login()
            }, label: {
                Text("Войти")
                    .padding()
                    .padding(.horizontal)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(26)
                    .padding(.top, 40)
            })
        }.adjustContent()
            .padding()
            .alert($alert)
    }

    private func login() {
        stateLoader.state = .show
        cancellable = NetworkService.login(.init(
            username: userName,
            password: password
        )).sink(
            receiveCompletion: {
                stateLoader.state = .hide
                switch $0 {
                case .failure(let error):
                    print(error)
                default:
                    break
                }
        }, receiveValue: {
            guard $0.error == nil else {
                alert = .init(title: "Error \(Int($0.code ?? 0))", message: $0.error?.first?.value.description ?? "")
                return
            }

            if $0.code == 200 {
                stateManager.state = .home
            }

            username = $0.data?.username ?? .empty
        })
    }

}

struct AuthView_Previews: PreviewProvider {

    static var previews: some View {
        AuthView()
    }

}

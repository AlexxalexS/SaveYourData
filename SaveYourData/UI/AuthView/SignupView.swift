//
//  SignupView.swift
//  SaveYourData
//
//  Created by Leha on 27.04.2022.
//

import SwiftUI
import Combine

struct SignupView: View {

    @Environment(\.presentationMode) var presentationMode

    @State private var cancellable: AnyCancellable?
    @ObservedObject var stateLoader = Loader.shared
    @State private var alert: AlertMessage?

    @State private var userName = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Имя пользователя", text: $userName)
                .font(Font.system(size: 14))
                .padding()
                .background(RoundedRectangle(cornerRadius: 50).fill(Color.gray.opacity(0.2)))
                .foregroundColor(.textField)
                .padding(.bottom)
                .offset(x: 8, y: 10)

            TextField("Email", text: $email)
                .font(Font.system(size: 14))
                .padding()
                .background(RoundedRectangle(cornerRadius: 50).fill(Color.gray.opacity(0.2)))
                .foregroundColor(.textField)
                .padding(.bottom)
                .offset(x: 8, y: 10)

            SecureField("Пароль", text: $password)
                .font(Font.system(size: 14))
                .padding()
                .background(RoundedRectangle(cornerRadius: 50).fill(Color.gray.opacity(0.2)))
                .foregroundColor(.textField)
                .padding(.bottom)
                .offset(x: 8, y: 10)

            Button(action: {
                signup()
            }, label: {
                Text("Зарегистрироваться")
                    .padding()
                    .padding(.horizontal)
                    .background(Color.mainButton)
                    .foregroundColor(.mainText)
                    .cornerRadius(26)
                    .padding(.top, 40)
            })
        }.adjustContent()
            .padding()
            .alert($alert)
    }

    private func signup() {
        if userName.isEmpty || password.isEmpty {
            alert = .init(title: "Ошибка", message: "Заполните все поля")
            return
        }
        stateLoader.state = .show
        cancellable = NetworkService.signup(.init(
            username: userName,
            email: email,
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

            if $0.code == 201 {
                alert = .init(
                    title: "Вы зарегистрировались",
                    message: "Войти в систему",
                    primaryButton: .default(Text("Ок"), action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                )
            }
        })
    }

}

struct SignupView_Previews: PreviewProvider {

    static var previews: some View {
        SignupView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }

}

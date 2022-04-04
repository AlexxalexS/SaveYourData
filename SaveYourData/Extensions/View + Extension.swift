import SwiftUI
import Combine

extension View {

    // MARK: - Выравнивание контента по центру
    func adjustContent() -> some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                self

                Spacer()
            }

            Spacer()
        }
    }

    // MARK: - Вызов alert на View
    func alert(_ item: Binding<AlertMessage?>) -> some View {
        self.alert(item: item) {
            .init(alert: $0)
        }
    }

}

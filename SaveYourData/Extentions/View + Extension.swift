import SwiftUI
import Combine

extension View {

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

    func alert(_ item: Binding<AlertMessage?>) -> some View {
        self.alert(item: item) {
            .init(alert: $0)
        }
    }


}

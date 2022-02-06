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

}

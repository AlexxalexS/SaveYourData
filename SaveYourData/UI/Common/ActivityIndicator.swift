import SwiftUI

struct LoaderView: View {

    var body: some View {
        VStack {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.loader)
                        .frame(width: 400, height: 400)
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(x: 1.2, y: 1.2, anchor: .center)
                }
            }
        }

    }

}

struct LoaderView_Previews: PreviewProvider {

    static var previews: some View {
        LoaderView()
            .preferredColorScheme(.light)
    }

}

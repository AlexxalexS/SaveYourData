
import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {

    var code = "Alex"
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack {
//            TextField(
//                "Code",
//                text: code
//            ).textContentType(.name)
//                .font(.title)
//                .padding(.horizontal)

            Spacer()

            Image(uiImage: generateQRCode(from: code))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                //.frame(width: 200, height: 200)

            Spacer()
        }.padding()
    }

    func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }

}

struct QRCode_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView()
    }
}

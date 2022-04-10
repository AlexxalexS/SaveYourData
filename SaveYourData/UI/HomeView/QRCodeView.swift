import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {

    var code = ""
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        Image(uiImage: generateQRCode(from: code))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .adjustContent()
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

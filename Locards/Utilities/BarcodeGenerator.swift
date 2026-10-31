import CoreImage.CIFilterBuiltins
import Foundation
import UIKit

enum BarcodeGenerator {
    // Creating a CIContext is expensive, so share one across calls
    private static let context = CIContext()

    static func image(for value: String, type: CardType) -> UIImage? {
        let filter: CIFilter

        switch type {
        case .barcode128:
            // Code 128 can only encode ASCII
            guard let data = value.data(using: .ascii) else {
                return nil
            }
            let code128 = CIFilter.code128BarcodeGenerator()
            code128.message = data
            // determines the space around and how tall the barcode generated should be
            code128.quietSpace = 5
            code128.barcodeHeight = 20
            filter = code128
        case .qr:
            let qr = CIFilter.qrCodeGenerator()
            qr.message = Data(value.utf8)
            // recovers up to 15% data damage
            qr.correctionLevel = "M"
            filter = qr
        case .pdf417:
            let pdf417 = CIFilter.pdf417BarcodeGenerator()
            pdf417.message = Data(value.utf8)
            filter = pdf417
        }

        guard let output = filter.outputImage else {
            return nil
        }
        guard let cgImage = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

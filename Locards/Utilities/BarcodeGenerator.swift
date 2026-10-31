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
            code128.quietSpace = 5
            code128.barcodeHeight = 20
            filter = code128
        case .qr:
            let qr = CIFilter.qrCodeGenerator()
            qr.message = Data(value.utf8)
            qr.correctionLevel = "M"
            filter = qr
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

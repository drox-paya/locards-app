import CoreImage.CIFilterBuiltins
import Foundation
import UIKit

public class BarcodeGenerator {
    static func image(for value: String, type: String) -> UIImage? {
        let context = CIContext()

        let code128Barcode = CIFilter.code128BarcodeGenerator()
        code128Barcode.message = value.data(using: .ascii)!
        code128Barcode.quietSpace = 5
        code128Barcode.barcodeHeight = 20

        guard let output = code128Barcode.outputImage else {
            return nil
        }
        guard let cgImage = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

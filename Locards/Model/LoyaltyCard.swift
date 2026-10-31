import Foundation
import SwiftData

enum CardType: String, Codable, CaseIterable {
    case barcode128 = "code128"
    case qr = "qr"
    case pdf417 = "pdf417"
}

@Model
class LoyaltyCard {
    var name: String
    var dateAdded: Date
    var barcodeString: String
    var barcodeType: CardType

    init(
        name: String = "", dateAdded: Date = Date.now, barcodeString: String = "",
        barcodeType: CardType = CardType.barcode128
    ) {
        self.name = name
        self.dateAdded = dateAdded
        self.barcodeString = barcodeString
        self.barcodeType = barcodeType
    }
}

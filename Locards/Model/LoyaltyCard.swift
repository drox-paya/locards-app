import Foundation
import SwiftData

enum CardType: String, Codable, CaseIterable {
    case barcode128 = "code128"
    case qr = "qr"

}

@Model
class LoyaltyCard {
    var id: Int
    var name: String
    var dateAdded: Date
    var barcodeString: String
    var barcodeType: CardType

    init(
        id: Int = 0, name: String = "", dateAdded: Date = Date.now, barcodeString: String = "",
        barcodeType: CardType = CardType.barcode128
    ) {
        self.id = id
        self.name = name
        self.dateAdded = dateAdded
        self.barcodeString = barcodeString
        self.barcodeType = barcodeType
    }
}

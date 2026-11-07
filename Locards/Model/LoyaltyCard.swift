import Foundation
import SwiftData

enum CardType: String, Codable, CaseIterable {
    case barcode128 = "code128"
    case qr = "qr"
    case pdf417 = "pdf417"

    var displayName: String {
        switch self {
        case .barcode128: return "Code 128"
        case .qr: return "QR Code"
        case .pdf417: return "PDF417"
        }
    }

    var showsNumber: Bool {
        self != .qr
    }

    func accepts(_ value: String) -> Bool {
        switch self {
        case .barcode128: return value.allSatisfy { $0.isASCII }
        case .qr, .pdf417: return true
        }
    }

    func validationMessage(for value: String) -> String? {
        guard !accepts(value) else { return nil }
        switch self {
        case .barcode128: return "Code 128 only supports standard ASCII characters."
        case .qr, .pdf417: return nil
        }
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

@Model
class LoyaltyCard {
    var name: String

    var dateAdded: Date
    var lastOpened: Date?
    var isPinned: Bool = false
    var barcodeString: String
    var barcodeType: CardType

    init(
        name: String = "", dateAdded: Date = Date.now, barcodeString: String = "",
        barcodeType: CardType = CardType.barcode128
    ) {
        self.name = name
        self.dateAdded = dateAdded
        self.lastOpened = nil
        self.isPinned = false
        self.barcodeString = barcodeString
        self.barcodeType = barcodeType
    }
}

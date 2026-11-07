import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CardRecord: Codable {
    let name: String
    let barcodeString: String
    let barcodeType: CardType
    let dateAdded: Date
    let lastOpened: Date?
    let isPinned: Bool

    init(card: LoyaltyCard) {
        name = card.name
        barcodeString = card.barcodeString
        barcodeType = card.barcodeType
        dateAdded = card.dateAdded
        lastOpened = card.lastOpened
        isPinned = card.isPinned
    }

    var isValid: Bool {
        let number = barcodeString.trimmed
        return !name.trimmed.isEmpty && !number.isEmpty && barcodeType.accepts(number)
    }

    func makeCard() -> LoyaltyCard {
        let card = LoyaltyCard(
            name: name.trimmed,
            dateAdded: dateAdded,
            barcodeString: barcodeString.trimmed,
            barcodeType: barcodeType
        )
        card.lastOpened = lastOpened
        card.isPinned = isPinned
        return card
    }

    static func encode(_ cards: [LoyaltyCard], customRetailers: [String] = []) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let envelope = CardsExport(
            version: CardsExport.currentVersion,
            cards: cards.map(CardRecord.init(card:)),
            customRetailers: customRetailers
        )
        return try encoder.encode(envelope)
    }

    static func decode(_ data: Data) throws -> CardsExport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CardsExport.self, from: data)
    }
}

struct CardsExport: Codable {
    static let currentVersion = 2

    let version: Int
    let cards: [CardRecord]
    let customRetailers: [String]
}

struct CardsDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CardRecord: Codable {
    let name: String
    let barcodeString: String
    let barcodeType: CardType
    let dateAdded: Date
    let lastOpened: Date?

    init(card: LoyaltyCard) {
        name = card.name
        barcodeString = card.barcodeString
        barcodeType = card.barcodeType
        dateAdded = card.dateAdded
        lastOpened = card.lastOpened
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
        return card
    }

    static func encode(_ cards: [LoyaltyCard]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(cards.map(CardRecord.init(card:)))
    }

    static func decode(_ data: Data) throws -> [CardRecord] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([CardRecord].self, from: data)
    }
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

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CardRecord: Codable {
    let name: String
    let barcodeString: String
    let barcodeType: CardType
    let dateAdded: Date
    let lastOpened: Date?
    let isPinned: Bool?

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
        card.isPinned = isPinned ?? false
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

    /// Accepts the v2 envelope, or the legacy v1 bare array of cards.
    static func decode(_ data: Data) throws -> CardsExport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(CardsExport.self, from: data)
        } catch {
            guard let legacy = try? decoder.decode([CardRecord].self, from: data) else { throw error }
            return CardsExport(version: 1, cards: legacy, customRetailers: [])
        }
    }
}

struct CardsExport: Codable {
    static let currentVersion = 2

    let version: Int
    let cards: [CardRecord]
    let customRetailers: [String]

    init(version: Int, cards: [CardRecord], customRetailers: [String]) {
        self.version = version
        self.cards = cards
        self.customRetailers = customRetailers
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = try c.decode(Int.self, forKey: .version)
        cards = try c.decode([CardRecord].self, forKey: .cards)
        customRetailers = try c.decodeIfPresent([String].self, forKey: .customRetailers) ?? []
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

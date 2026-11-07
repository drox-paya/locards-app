import Foundation
import SwiftData
import Testing

@testable import Locards

struct CardTypeTests {
    @Test func code128RejectsNonASCII() {
        #expect(CardType.barcode128.accepts("ABC-123"))
        #expect(!CardType.barcode128.accepts("café"))
        #expect(CardType.barcode128.validationMessage(for: "café") != nil)
    }

    @Test func qrAndPDF417AcceptAnything() {
        #expect(CardType.qr.accepts("café ☕️"))
        #expect(CardType.pdf417.accepts("anything"))
    }
}

struct CardRecordTests {
    private let v1 = """
        [{"name":"Coles","barcodeString":"123","barcodeType":"code128","dateAdded":"2026-01-01T00:00:00Z"}]
        """

    @Test func decodesLegacyArray() throws {
        let export = try CardRecord.decode(Data(v1.utf8))
        #expect(export.version == 1)
        #expect(export.cards.count == 1)
        #expect(export.cards[0].isPinned == nil)
        #expect(export.customRetailers.isEmpty)
    }

    @Test func roundTripsV2() throws {
        let card = LoyaltyCard(name: "Coles", barcodeString: "123", barcodeType: .qr)
        card.isPinned = true
        let data = try CardRecord.encode([card], customRetailers: ["Corner Shop"])
        let export = try CardRecord.decode(data)
        #expect(export.version == CardsExport.currentVersion)
        #expect(export.cards.first?.isPinned == true)
        #expect(export.cards.first?.barcodeType == .qr)
        #expect(export.customRetailers == ["Corner Shop"])
    }

    @Test func rejectsGarbage() {
        #expect(throws: (any Error).self) { try CardRecord.decode(Data("nope".utf8)) }
    }
}

@MainActor
struct ImportTests {
    private var keepAlive: [ModelContainer] = []

    private mutating func makeVM() throws -> HomeViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: LoyaltyCard.self, CustomRetailer.self, configurations: config)
        keepAlive.append(container)
        return HomeViewModel(context: container.mainContext)
    }

    private func export(_ json: String) throws -> CardsExport {
        try CardRecord.decode(Data(json.utf8))
    }

    @Test mutating func addsDedupesAndSkips() throws {
        let vm = try makeVM()
        let json = """
            [{"name":"A","barcodeString":"1","barcodeType":"code128","dateAdded":"2026-01-01T00:00:00Z"},
             {"name":"A","barcodeString":"1","barcodeType":"code128","dateAdded":"2026-01-01T00:00:00Z"},
             {"name":" ","barcodeString":"2","barcodeType":"qr","dateAdded":"2026-01-01T00:00:00Z"},
             {"name":"B","barcodeString":"é","barcodeType":"code128","dateAdded":"2026-01-01T00:00:00Z"}]
            """
        let first = vm.importCards(try export(json))
        #expect(first.added == 1)
        #expect(first.skipped == 2)
        #expect(vm.savedCards.count == 1)
        let second = vm.importCards(try export(json))
        #expect(second.added == 0)
    }

    @Test mutating func keepsOnlyOnePinnedAndImportsRetailers() throws {
        let vm = try makeVM()
        let json = """
            {"version":2,"customRetailers":["Corner Shop","Coles","Corner Shop"],"cards":[
             {"name":"A","barcodeString":"1","barcodeType":"qr","dateAdded":"2026-01-01T00:00:00Z","isPinned":true},
             {"name":"B","barcodeString":"2","barcodeType":"qr","dateAdded":"2026-01-01T00:00:00Z","isPinned":true}]}
            """
        _ = vm.importCards(try export(json))
        #expect(vm.savedCards.filter(\.isPinned).count == 1)
        #expect(vm.customRetailerNames == ["Corner Shop"])
    }

    @Test mutating func updateChangesCard() throws {
        let vm = try makeVM()
        let card = LoyaltyCard(name: "A", barcodeString: "1", barcodeType: .qr)
        vm.addCard(card: card)
        vm.update(card: card, name: " B ", number: " 22 ", type: .pdf417)
        #expect(vm.savedCards.first?.name == "B")
        #expect(vm.savedCards.first?.barcodeString == "22")
        #expect(vm.savedCards.first?.barcodeType == .pdf417)
    }
}

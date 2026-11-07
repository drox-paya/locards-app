import Foundation
import SwiftData

enum SortOption: String, CaseIterable, Identifiable {
    case recentlyOpened = "Recently opened"
    case recentlyAdded = "Recently added"
    case alphabetical = "Alphabetical (A–Z)"

    var id: String { rawValue }
}

@Observable
final class HomeViewModel {
    let context: ModelContext
    var savedCards: [LoyaltyCard] = []
    var sortOption: SortOption = .alphabetical {
        didSet { load() }
    }

    init(context: ModelContext) {
        self.context = context
    }
    func load() {
        let descriptor = FetchDescriptor<LoyaltyCard>()
        let cards = (try? context.fetch(descriptor)) ?? []
        switch sortOption {
        case .recentlyOpened:
            savedCards = cards.sorted { ($0.lastOpened ?? .distantPast) > ($1.lastOpened ?? .distantPast) }
        case .recentlyAdded:
            savedCards = cards.sorted { $0.dateAdded > $1.dateAdded }
        case .alphabetical:
            savedCards = cards.sorted { $0.name < $1.name }
        }
    }
    func addCard(card: LoyaltyCard) {
        context.insert(card)
        save()
        // do we need to load here?
        load()
    }
    func delete(card: LoyaltyCard) {
        context.delete(card)
        save()
        load()
    }
    func update(card: LoyaltyCard, name: String, number: String, type: CardType) {
        card.name = name.trimmed
        card.barcodeString = number.trimmed
        card.barcodeType = type
        save()
        load()
    }
    var customRetailerNames: [String] {
        let all = (try? context.fetch(FetchDescriptor<CustomRetailer>())) ?? []
        return all.map(\.name).sorted()
    }
    func importCards(_ export: CardsExport) -> (added: Int, skipped: Int) {
        var known = Set(savedCards.map { "\($0.name)|\($0.barcodeString)" })
        var hasPinned = pinnedCard != nil
        var added = 0
        var skipped = 0
        for record in export.cards {
            guard record.isValid else {
                skipped += 1
                continue
            }
            let key = "\(record.name.trimmed)|\(record.barcodeString.trimmed)"
            guard !known.contains(key) else { continue }
            known.insert(key)
            let card = record.makeCard()
            if card.isPinned && hasPinned { card.isPinned = false }
            hasPinned = hasPinned || card.isPinned
            context.insert(card)
            added += 1
        }
        var knownRetailers = Set(customRetailerNames)
        for name in export.customRetailers.map(\.trimmed) where !name.isEmpty {
            guard !Retailer.allCases.contains(where: { $0.rawValue == name }),
                knownRetailers.insert(name).inserted
            else { continue }
            context.insert(CustomRetailer(name: name))
        }
        save()
        load()
        return (added, skipped)
    }
    var pinnedCard: LoyaltyCard? {
        savedCards.first { $0.isPinned }
    }
    func togglePin(card: LoyaltyCard) {
        if card.isPinned {
            card.isPinned = false
        } else {
            for other in savedCards where other.isPinned {
                other.isPinned = false
            }
            card.isPinned = true
        }
        save()
        load()
    }
    private func save() {
        try? context.save()
    }

}

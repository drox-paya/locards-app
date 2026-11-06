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
    func importCards(_ records: [CardRecord]) -> (added: Int, skipped: Int) {
        var known = Set(savedCards.map { "\($0.name)|\($0.barcodeString)" })
        var added = 0
        var skipped = 0
        for record in records {
            guard record.isValid else {
                skipped += 1
                continue
            }
            let key = "\(record.name.trimmed)|\(record.barcodeString.trimmed)"
            guard !known.contains(key) else { continue }
            known.insert(key)
            context.insert(record.makeCard())
            added += 1
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

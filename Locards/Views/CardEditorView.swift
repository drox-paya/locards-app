import SwiftData
import SwiftUI

enum CardEditorMode {
    case add
    case edit(LoyaltyCard)
}

struct CardEditorView: View {
    let viewmodel: HomeViewModel
    let mode: CardEditorMode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomRetailer.name) private var customRetailers: [CustomRetailer]
    @State private var retailerName: String
    @State private var cardName: String
    @State private var cardNumber: String
    @State private var cardType: CardType
    @State private var saveRetailer: Bool = false

    init(viewmodel: HomeViewModel, mode: CardEditorMode = .add) {
        self.viewmodel = viewmodel
        self.mode = mode
        switch mode {
        case .add:
            _retailerName = State(initialValue: "")
            _cardName = State(initialValue: "")
            _cardNumber = State(initialValue: "")
            _cardType = State(initialValue: .barcode128)
        case .edit(let card):
            let known = Retailer(rawValue: card.name) != nil
            _retailerName = State(initialValue: known ? card.name : "")
            _cardName = State(initialValue: card.name)
            _cardNumber = State(initialValue: card.barcodeString)
            _cardType = State(initialValue: card.barcodeType)
        }
    }

    private var editingCard: LoyaltyCard? {
        if case .edit(let card) = mode { return card }
        return nil
    }

    var body: some View {
        Form {
            Section("Retailer") {
                NavigationLink {
                    RetailerListView(selection: $retailerName)
                } label: {
                    LabeledContent("Retailer", value: retailerName.isEmpty ? "Other" : retailerName)
                }
                .onChange(of: retailerName) { _, newValue in
                    cardName = newValue
                }
            }

            Section("Card Details") {
                TextField("Card Name", text: $cardName)
                TextField("Card Number", text: $cardNumber)
                if !cardNumber.trimmed.isEmpty, let problem = cardType.validationMessage(for: cardNumber.trimmed) {
                    Text(problem)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                Picker("Barcode Type", selection: $cardType) {
                    ForEach(CardType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                if editingCard == nil && retailerName.isEmpty {
                    Toggle("Save as a retailer", isOn: $saveRetailer)
                }
            }

            Section {
                Button("Save") {
                    save()
                }
                .disabled(!isValid)
            }
        }
        .navigationTitle(editingCard == nil ? "New Card" : "Edit Card")
        .toolbar {
            if editingCard != nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var isValid: Bool {
        !cardName.trimmed.isEmpty && !cardNumber.trimmed.isEmpty && cardType.accepts(cardNumber.trimmed)
    }

    private func save() {
        let name = cardName.trimmed
        if editingCard == nil && retailerName.isEmpty && saveRetailer
            && !Retailer.allCases.contains(where: { $0.rawValue == name })
            && !customRetailers.contains(where: { $0.name == name }) {
            modelContext.insert(CustomRetailer(name: name))
        }
        if let card = editingCard {
            viewmodel.update(card: card, name: name, number: cardNumber, type: cardType)
        } else {
            let card = LoyaltyCard(
                name: name,
                barcodeString: cardNumber.trimmed,
                barcodeType: cardType
            )
            viewmodel.addCard(card: card)
        }
        dismiss()
    }
}

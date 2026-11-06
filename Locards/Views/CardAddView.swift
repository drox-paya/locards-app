import SwiftData
import SwiftUI

struct CardAddView: View {
    let viewmodel: HomeViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomRetailer.name) private var customRetailers: [CustomRetailer]
    @State var retailerName: String = ""
    @State var cardName: String = ""
    @State var cardNumber: String = ""
    @State var cardType: CardType = CardType.barcode128
    @State var saveRetailer: Bool = false

    var body: some View {
        Form {
            Section("Retailer") {
                NavigationLink {
                    RetailerListView(selection: $retailerName)
                } label: {
                    LabeledContent("Retailer", value: retailerName.isEmpty ? "Other" : retailerName)
                }
                .onChange(of: retailerName) { _, newValue in
                    if !newValue.isEmpty {
                        cardName = newValue
                    }
                }
            }

            Section("Card Details") {
                TextField("Card Name", text: $cardName)
                TextField("Card Number", text: $cardNumber)
                Picker("Barcode Type", selection: $cardType) {
                    ForEach(CardType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                if retailerName.isEmpty {
                    Toggle("Save as a retailer", isOn: $saveRetailer)
                }
            }

            Section {
                Button("Save") {
                    save()
                }
                .disabled(cardName.isEmpty || cardNumber.isEmpty)
            }
        }
        .navigationTitle("New Card")
    }

    private func save() {
        if retailerName.isEmpty && saveRetailer
            && !Retailer.allCases.contains(where: { $0.rawValue == cardName })
            && !customRetailers.contains(where: { $0.name == cardName }) {
            modelContext.insert(CustomRetailer(name: cardName))
        }
        let card = LoyaltyCard(
            name: cardName,
            barcodeString: cardNumber,
            barcodeType: cardType
        )
        viewmodel.addCard(card: card)
        dismiss()
    }
}

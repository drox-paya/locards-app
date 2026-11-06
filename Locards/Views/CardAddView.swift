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
                    cardName = newValue
                }
            }

            Section("Card Details") {
                TextField("Card Name", text: $cardName)
                TextField("Card Number", text: $cardNumber)
                if !cardNumber.trimmed.isEmpty && !cardType.accepts(cardNumber.trimmed) {
                    Text("Code 128 only supports standard ASCII characters.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
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
                .disabled(!isValid)
            }
        }
        .navigationTitle("New Card")
    }

    private var isValid: Bool {
        !cardName.trimmed.isEmpty && !cardNumber.trimmed.isEmpty && cardType.accepts(cardNumber.trimmed)
    }

    private func save() {
        let name = cardName.trimmed
        if retailerName.isEmpty && saveRetailer
            && !Retailer.allCases.contains(where: { $0.rawValue == name })
            && !customRetailers.contains(where: { $0.name == name }) {
            modelContext.insert(CustomRetailer(name: name))
        }
        let card = LoyaltyCard(
            name: name,
            barcodeString: cardNumber.trimmed,
            barcodeType: cardType
        )
        viewmodel.addCard(card: card)
        dismiss()
    }
}

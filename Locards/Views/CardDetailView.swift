import SwiftUI

struct CardDetailView: View {
    let card: LoyaltyCard
    var body: some View {
        VStack {
            Text(card.name)
                .font(.title)
            if let img = BarcodeGenerator.image(for: card.barcodeString, type: card.barcodeType) {
                Image(uiImage: img)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
            }
        }
        .padding()
        .onAppear {
            card.lastOpened = .now
        }
    }
}

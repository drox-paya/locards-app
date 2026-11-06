import SwiftUI
import UIKit

struct CardDetailView: View {
    let card: LoyaltyCard
    @State private var originalBrightness: CGFloat?

    private var screen: UIScreen? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.screen
    }

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
                    .padding()
                    .background(.white, in: RoundedRectangle(cornerRadius: 8))
                    .accessibilityLabel("Barcode for \(card.name)")
                if card.barcodeType.showsNumber {
                    Text(card.barcodeString)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .padding()
        .onAppear {
            card.lastOpened = .now
            originalBrightness = screen?.brightness
            screen?.brightness = 1
        }
        .onDisappear {
            if let originalBrightness {
                screen?.brightness = originalBrightness
            }
        }
    }
}

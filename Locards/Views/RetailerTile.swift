import SwiftUI

struct RetailerTile: View {
    let name: String
    let retailer: Retailer?

    var body: some View {
        ZStack {
            if let retailer {
                retailer.brandColor
            } else {
                Color(.systemGray4)
            }
            Text(label)
                .font(.headline.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(textColor)
                .padding(8)
        }
    }

    private var label: String {
        guard let retailer else { return name }
        return "\(retailer.emoji) \(name)"
    }

    private var textColor: Color {
        guard let retailer else { return .primary }
        return retailer.prefersDarkText ? .black : .white
    }
}

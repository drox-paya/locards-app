import SwiftData
import SwiftUI

struct RetailerListView: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomRetailer.name) private var customRetailers: [CustomRetailer]
    @State private var searchText: String = ""

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    private var filteredRetailers: [Retailer] {
        searchText.isEmpty
            ? Retailer.allCases
            : Retailer.allCases.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
    }

    private var filteredCustomRetailers: [CustomRetailer] {
        searchText.isEmpty
            ? customRetailers
            : customRetailers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                if searchText.isEmpty {
                    RetailerCard(title: "Other", isSelected: selection.isEmpty, action: {
                        select("")
                    }, logo: {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .scaledToFit()
                    })
                }
                ForEach(filteredRetailers) { retailer in
                    RetailerCard(title: retailer.rawValue, isSelected: selection == retailer.rawValue, action: {
                        select(retailer.rawValue)
                    }, logo: {
                        Image(retailer.logoName)
                            .resizable()
                            .scaledToFit()
                    })
                }
                ForEach(filteredCustomRetailers) { retailer in
                    RetailerCard(title: retailer.name, isSelected: selection == retailer.name, action: {
                        select(retailer.name)
                    }, logo: {
                        Image(systemName: "storefront")
                            .resizable()
                            .scaledToFit()
                    })
                }
            }
            .padding()
        }
        .navigationTitle("Retailers")
        .searchable(text: $searchText, prompt: "Search retailers")
    }

    private func select(_ name: String) {
        selection = name
        dismiss()
    }
}

private struct RetailerCard<Logo: View>: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let logo: Logo

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                logo
                    .frame(height: 60)
                Text(title)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

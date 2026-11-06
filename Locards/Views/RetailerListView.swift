import SwiftData
import SwiftUI

struct RetailerListView: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomRetailer.name) private var customRetailers: [CustomRetailer]
    @State private var searchText: String = ""
    @State private var categoryFilter: RetailerCategory?
    @State private var groupByCategory: Bool = false

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    private var filteredRetailers: [Retailer] {
        Retailer.allCases.filter { retailer in
            (categoryFilter == nil || retailer.category == categoryFilter)
                && (searchText.isEmpty || retailer.rawValue.localizedCaseInsensitiveContains(searchText))
        }
    }

    private var filteredCustomRetailers: [CustomRetailer] {
        guard categoryFilter == nil else { return [] }
        return searchText.isEmpty
            ? customRetailers
            : customRetailers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                if searchText.isEmpty && categoryFilter == nil {
                    RetailerCard(title: "Other", retailer: nil, isSelected: selection.isEmpty) {
                        select("")
                    }
                }
                if groupByCategory {
                    ForEach(RetailerCategory.allCases) { category in
                        let retailers = filteredRetailers.filter { $0.category == category }
                        if !retailers.isEmpty {
                            Section {
                                retailerCards(retailers)
                            } header: {
                                sectionHeader(category.rawValue)
                            }
                        }
                    }
                    if !filteredCustomRetailers.isEmpty {
                        Section {
                            customCards
                        } header: {
                            sectionHeader("Custom")
                        }
                    }
                } else {
                    retailerCards(filteredRetailers)
                    customCards
                }
            }
            .padding()
        }
        .navigationTitle("Retailers")
        .searchable(text: $searchText, prompt: "Search retailers")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Category", selection: $categoryFilter) {
                        Text("All Categories").tag(RetailerCategory?.none)
                        ForEach(RetailerCategory.allCases) { category in
                            Text(category.rawValue).tag(Optional(category))
                        }
                    }
                    Toggle("Group by Category", isOn: $groupByCategory)
                } label: {
                    Image(systemName: categoryFilter == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
            }
        }
    }

    @ViewBuilder
    private func retailerCards(_ retailers: [Retailer]) -> some View {
        ForEach(retailers) { retailer in
            RetailerCard(title: retailer.rawValue, retailer: retailer, isSelected: selection == retailer.rawValue) {
                select(retailer.rawValue)
            }
        }
    }

    @ViewBuilder
    private var customCards: some View {
        ForEach(filteredCustomRetailers) { retailer in
            RetailerCard(title: retailer.name, retailer: nil, isSelected: selection == retailer.name) {
                select(retailer.name)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private func select(_ name: String) {
        selection = name
        dismiss()
    }
}

private struct RetailerCard: View {
    let title: String
    let retailer: Retailer?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RetailerTile(name: title, retailer: retailer)
                .frame(maxWidth: .infinity, minHeight: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

struct HomeView: View {
    @State private var homeVM: HomeViewModel
    init(homeVM: HomeViewModel) {
        _homeVM = State(initialValue: homeVM)
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let pinned = homeVM.pinnedCard {
                        pinnedSection(for: pinned)
                    }
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(homeVM.savedCards.filter { !$0.isPinned }) { card in
                            NavigationLink(destination: CardDetailView(card: card)) {
                                cardTile(for: card)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                pinButton(for: card)
                                Button(role: .destructive) {
                                    homeVM.delete(card: card)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort by", selection: $homeVM.sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: CardAddView(viewmodel: homeVM)) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Locards")
            .onAppear {
                homeVM.load()
            }
        }
    }

    private func pinnedSection(for card: LoyaltyCard) -> some View {
        NavigationLink(destination: CardDetailView(card: card)) {
            VStack(spacing: 8) {
                Text(card.name)
                    .font(.headline)
                if let img = BarcodeGenerator.image(for: card.barcodeString, type: card.barcodeType) {
                    Image(uiImage: img)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(8)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                        .accessibilityLabel("Barcode for \(card.name)")
                }
                if card.barcodeType.showsNumber {
                    Text(card.barcodeString)
                        .font(.system(.body, design: .monospaced))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            pinButton(for: card)
        }
    }

    private func pinButton(for card: LoyaltyCard) -> some View {
        Button {
            homeVM.togglePin(card: card)
        } label: {
            Label(card.isPinned ? "Unpin" : "Pin", systemImage: card.isPinned ? "pin.slash" : "pin")
        }
    }

    private func cardTile(for card: LoyaltyCard) -> some View {
        RetailerTile(name: card.name, retailer: Retailer(rawValue: card.name))
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

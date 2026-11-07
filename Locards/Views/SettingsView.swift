import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let homeVM: HomeViewModel

    @AppStorage("appearance") private var appearance: AppearanceMode = .system
    @State private var exportDocument = CardsDocument()
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var message: String?
    @State private var recoveredFiles = StoreRecovery.recoveredFiles()

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Dark Mode", selection: $appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                }

                Section("Cards") {
                    Button("Export Cards") {
                        exportCards()
                    }
                    Button("Import Cards") {
                        isImporting = true
                    }
                }

                if !recoveredFiles.isEmpty {
                    Section {
                        ShareLink("Export recovered data", items: recoveredFiles)
                    } header: {
                        Text("Recovery")
                    } footer: {
                        Text("Locards couldn't open its data and kept a copy of it. Save these files somewhere safe.")
                    }
                }
            }
            .navigationTitle("Settings")
            .fileExporter(
                isPresented: $isExporting,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "Locards Cards"
            ) { result in
                if case .failure(let error) = result, (error as? CocoaError)?.code != .userCancelled {
                    message = "Export failed: \(error.localizedDescription)"
                }
            }
            .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
                importCards(from: result)
            }
            .alert(
                "Locards",
                isPresented: Binding(
                    get: { message != nil },
                    set: { if !$0 { message = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(message ?? "")
            }
        }
    }

    private func exportCards() {
        do {
            exportDocument = CardsDocument(data: try CardRecord.encode(homeVM.savedCards, customRetailers: homeVM.customRetailerNames))
            isExporting = true
        } catch {
            message = "Export failed: \(error.localizedDescription)"
        }
    }

    private func importCards(from result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed { url.stopAccessingSecurityScopedResource() }
            }
            do {
                let export = try CardRecord.decode(Data(contentsOf: url))
                let result = homeVM.importCards(export)
                var text = "Imported \(result.added) new card(s)."
                if result.skipped > 0 {
                    text += " Skipped \(result.skipped) invalid card(s)."
                }
                message = text
            } catch {
                message = "Import failed: \(error.localizedDescription)"
            }
        case .failure(let error):
            message = "Import failed: \(error.localizedDescription)"
        }
    }
}

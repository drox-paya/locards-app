# AGENTS.md

Guide for AI agents working in this repo. Keep this file accurate: **when you add, rename, move or remove files, or change how the app is structured, update this file in the same change.**

## What the app is

Locards is an iOS SwiftUI app (iOS 26 SDK, Swift 5 language mode, Xcode project `Locards.xcodeproj`, single target `Locards`). It stores loyalty cards (name, barcode number, barcode type) with SwiftData and displays their barcodes. Users can pick a suggested Australian retailer or enter their own, sort and pin cards, and import/export cards as JSON. Dark mode can be set in Settings.

## Build and check

```sh
xcodebuild -project Locards.xcodeproj -scheme Locards -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

Always run this after changes and confirm `** BUILD SUCCEEDED **`. Don't use `*.xcworkspace` (there isn't one). The project has `-default-isolation MainActor`, so types are main-actor isolated by default.

## Folder layout

```
Locards/
  LocardsApp.swift            @main. Builds the SwiftData ModelContainer and HomeViewModel; root scene shows ContentView.
  ContentView.swift           Root TabView (Home, Settings). Applies the dark mode setting via .preferredColorScheme.
  Model/
    LoyaltyCard.swift         @Model card (name, dateAdded, lastOpened, isPinned, barcodeString, barcodeType). Also the CardType enum.
    CustomRetailer.swift      @Model user-added retailer name.
    Retailer.swift            Enum of suggested retailers. rawValue is the display name; logoName is the asset name ("logo_<caseName>").
    AppearanceMode.swift      Enum for System/Light/Dark, backed by @AppStorage("appearance").
    CardTransfer.swift        CardRecord (Codable JSON DTO) and CardsDocument (FileDocument for export).
  Viewmodels/
    HomeViewModel.swift       Owns ModelContext and savedCards. Load, sort (SortOption), add, delete, pin, import.
    CardDetailViewModel.swift EMPTY placeholder. Not used yet.
  Views/
    HomeView.swift            Pinned card section, 2-column grid of cards, sort menu, add button.
    CardDetailView.swift      Shows a card's name and barcode. Sets lastOpened on appear.
    CardAddView.swift         Form to create a card. Opens RetailerListView. Saves CustomRetailer when asked.
    RetailerListView.swift    Searchable grid of retailer cards (suggested + custom + "Other").
    SettingsView.swift        Dark mode picker, export and import of cards.
  Utilities/
    BarcodeGenerator.swift    CIFilter-based image generation for code128, QR and PDF417.
  Assets.xcassets/
    logo_<caseName>.imageset  One placeholder image per Retailer case (grey square). Replace the PNGs with real logos.
    AppIcon, AccentColor
```

## Data model

- `LoyaltyCard` is the main model. `CardType` is `code128`, `qr` or `pdf417`, with `displayName` for the UI.
- A card's `name` is also used to match a suggested retailer: `Retailer(rawValue: card.name)` gives its logo. Keep this in mind when changing how names are stored.
- `CustomRetailer` holds retailers the user typed in and chose to save.
- Only one card can be pinned. `HomeViewModel.togglePin` unpins the others.
- The `ModelContainer` in `LocardsApp.init` lists every `@Model` type. **Any new `@Model` must be added there.**
- Changing the schema: new stored properties need a default value (for example `var isPinned: Bool = false`). Without one, existing stores fail to open and the app quits at launch. A `fatalError` in `LocardsApp.init` reports the error.

## Conventions

- Views read data from `HomeViewModel`. They don't fetch from SwiftData directly, except `@Query` for `CustomRetailer` in `CardAddView` and `RetailerListView`.
- Mutations go through `HomeViewModel` methods (`addCard`, `delete`, `deleteCards`, `togglePin`, `importCards`, `load`). Each one saves and reloads `savedCards`.
- Sorting is done in memory in `HomeViewModel.load()`, based on `sortOption`.
- Use `Retailer` for suggested retailers and `CustomRetailer` for user-added ones. Don't hard-code retailer names elsewhere.
- Logos use `Image(retailer.logoName)`. Don't rename the asset sets without updating `Retailer.logoName`.
- Keep the existing comment style: few comments, only where the code isn't obvious.

## Known gaps

- `CardDetailViewModel.swift` is empty.
- Custom retailers can't be edited or deleted.
- Import and export don't include custom retailers.
- The retailer list has placeholder logos and default barcode types aren't set per retailer.
- Pinned state isn't exported.
- Nothing is covered by tests. Verify by building and running the app.

## Updating this file

When you make a change that affects the items above, update the matching section here in the same change. This includes new or moved files, new models, new view model methods, changed sort or pin behaviour, and anything that's fixed from "Known gaps".

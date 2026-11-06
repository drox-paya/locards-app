//
//  LocardsApp.swift
//  Locards
//
//  Created by Braiden Webb on 31/10/2026.
//

import SwiftData
import SwiftUI

@main
struct LocardsApp: App {
    let container: ModelContainer
    let homeVM: HomeViewModel

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: LoyaltyCard.self, CustomRetailer.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        self.container = container
        self.homeVM = HomeViewModel(context: container.mainContext)
    }
    var body: some Scene {
        WindowGroup {
            ContentView(viewmodel: homeVM)
        }.modelContainer(container)
    }
}

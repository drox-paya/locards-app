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
    let recovered: Bool

    init() {
        let result = StoreRecovery.makeContainer()
        container = result.container
        recovered = result.recovered
        homeVM = HomeViewModel(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewmodel: homeVM, recovered: recovered)
        }.modelContainer(container)
    }
}

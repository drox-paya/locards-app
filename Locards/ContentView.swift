//
//  ContentView.swift
//  Locards
//
//  Created by Braiden Webb on 31/10/2026.
//

import SwiftUI

struct ContentView: View {
    var viewmodel: HomeViewModel
    @AppStorage("appearance") private var appearance: AppearanceMode = .system

    var body: some View {
        TabView {
            HomeView(homeVM: viewmodel).tabItem {
                Label("Home", systemImage: "house.fill")
            }
            SettingsView(homeVM: viewmodel).tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}

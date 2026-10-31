//
//  ContentView.swift
//  Locards
//
//  Created by Braiden Webb on 31/10/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Barcode Test Generation")
            if let img = BarcodeGenerator.image(for: "123456789", type: .barcode128) {
                Image(uiImage: img).interpolation(.none).resizable().frame(height: 100)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

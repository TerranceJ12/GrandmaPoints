//
//  ContentView.swift
//  GrandmaPoints
//
//  Created by Terrance Johnson Jr on 1/28/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        KidsListView()
            .accentColor(AppTheme.primaryColor) // Set app-wide accent color
    }
}

#Preview {
    ContentView()
}

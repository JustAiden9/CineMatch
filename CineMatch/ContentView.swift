//
//  ContentView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 8) {
                    Text("CineMatch")
                        .font(.largeTitle).bold()
                    Text("Movie matchup party game")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                NavigationLink {
                    SplitScreenView()
                } label: {
                    Label("Start Game", systemImage: "play.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}

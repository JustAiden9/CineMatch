//
//  SplitScreenView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct SplitScreenView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Player 2 (Top)
            PlayerZoneView(playerID: 2)
                .rotationEffect(.degrees(180))
                .ignoresSafeArea()

            // Divider
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.gray)

            // Player 1 (Bottom)
            PlayerZoneView(playerID: 1)
                .ignoresSafeArea()
        }
    }
}

struct PlayerZoneView: View {
    let playerID: Int
    var body: some View {
        ZStack {
            Color.clear
            Text("Player \(playerID) Zone")
                .font(.headline)
        }
        .frame(height: 300)
    }
}

#Preview {
    SplitScreenView()
}

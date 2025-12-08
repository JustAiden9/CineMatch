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
            PlayerView(playerID: 2)
                .rotationEffect(.degrees(180))
            // Player 1 (Bottom)
            PlayerView(playerID: 1)

        }
    }
}

struct PlayerView: View {
    let playerID: Int
    var body: some View {
        ZStack {
            Color.clear
            MovieCardView()
        }
    }
}

#Preview {
    SplitScreenView()
}

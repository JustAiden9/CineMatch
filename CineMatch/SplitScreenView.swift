//
//  SplitScreenView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct SplitScreenView: View {
    let apiKey: String
    
    // @StateObject: We create the GameManager here. This object "owns" the data/the api response.
    @StateObject private var gameManager = GameManager()
    // Track if each player has finished swiping their deck
    @State private var player1Done: Bool = false
    @State private var player2Done: Bool = false
    @State private var showSummary: Bool = false  // Controls when to pop up the final results

    var body: some View {
        ZStack {
            // RadialGradient gives it that glow in the center, I had a lot of fun with this and I think it looks good
            RadialGradient(
                gradient: Gradient(colors: [Color(white: 0.15), Color.black]),
                center: .center,
                startRadius: 5,
                endRadius: 600
            )
            .ignoresSafeArea() // Makes sure the background goes behind the notch/battery bar
            
            // We stack two PlayerViews vertically
            VStack(spacing: 0) {
                // PLAYER 2 (Top Half)
                // We rotate this view 180 degrees so the person sitting across from you can see their cards
                PlayerView(playerID: 2, gameManager: gameManager, onFinished: {
                    player2Done = true
                    checkIfGameFinished()
                })
                .rotationEffect(.degrees(180))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // DIVIDER
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, .white.opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing)) // Used a LinearGradient for this becuase it is a line rather than a circle
                    .frame(height: 1)
                    .shadow(color: .white.opacity(0.5), radius: 5)
                
                // PLAYER 1 (Bottom Half)
                PlayerView(playerID: 1, gameManager: gameManager, onFinished: {
                    player1Done = true
                    checkIfGameFinished()
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
            // This sits on top of everything (ZStack layer).
            // It only appears when 'showSummary' becomes true.
            if showSummary {
                MatchSummaryView(matches: gameManager.matches) {
                    // This closure runs when the Close button is clciked
                    withAnimation { showSummary = false }
                }
                .transition(.opacity.combined(with: .scale)) // Fade in + Scale up animation
            }
        }
        .task {
            // As soon as this view appears, start downloading movies.
            // 'await' means we wait for the download to finish without freezing the app
            await gameManager.fetchPopularMovies(apiKey: apiKey)
        }
    }
    
    // Helper: Logic to check if the game is over
    private func checkIfGameFinished() {
        if player1Done && player2Done {
            // Triggers the UI update to show the summary
            withAnimation { showSummary = true }
        }
    }
}

// Players cards/movies
// I made this so we didn't have to copy-paste the code for Player 1 and Player 2.
// Players cards/movies
struct PlayerView: View {
    let playerID: Int
    @ObservedObject var gameManager: GameManager
    var onFinished: (() -> Void)? = nil
    @State private var playerDeck: [Movie] = []
    @State private var didNotifyFinished: Bool = false
    
    // Only render top 3 cards for performance
    var visibleMovies: [Movie] {
        Array(playerDeck.prefix(3))
    }
    
    var body: some View {
        ZStack {
            // We place this first in the ZStack so it sits BEHIND the cards
            HStack {
                // Left Side: X (Dislike)
                Image(systemName: "xmark")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3)) // Low opacity so it isn't distracting
                    .padding(.leading, 30)
                
                Spacer()
                
                // Right Side: Check (Like)
                Image(systemName: "checkmark")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.trailing, 30)
            }
            .frame(maxWidth: .infinity)
            // Important: This allows touches to pass through the icons to the cards
            .allowsHitTesting(false)
            
            if playerDeck.isEmpty {
                // Empty State: What shows when cards run out
                VStack(spacing: 15) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("Waiting for other player...")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
            } else {
                // Card Stack
                ZStack {
                    // We reverse the array so index 0 is drawn LAST (on top)
                    ForEach(Array(visibleMovies.enumerated().reversed()), id: \.element.id) { index, movie in
                        let isTopCard = index == 0
                        
                        MovieCardView(
                            movie: movie,
                            onSwipeRight: {
                                gameManager.recordDecision(playerID: playerID, movie: movie, liked: true)
                                removeFromLocalDeck(movie.id)
                            },
                            onSwipeLeft: {
                                gameManager.recordDecision(playerID: playerID, movie: movie, liked: false)
                                removeFromLocalDeck(movie.id)
                            }
                        )
                        // Visual Depth Logic
                        .scaleEffect(isTopCard ? 1.0 : 0.9 + (Double(index) * 0.05))
                        .offset(y: isTopCard ? 0 : 25)
                        .opacity(isTopCard ? 1.0 : 0.5)
                        .allowsHitTesting(isTopCard) // You can only touch the top card
                    }
                }
            }
        }
        // Listen for when the GameManager actually finishes downloading movies
        .onReceive(gameManager.$movies) { newMovies in
            if playerDeck.isEmpty {
                playerDeck = newMovies
            }
        }
        // Monitor when the deck becomes empty to end the game
        .onChange(of: playerDeck.isEmpty) { oldValue, newValue in
            if newValue && !didNotifyFinished {
                didNotifyFinished = true
                onFinished?()
            }
        }
    }
    
    private func removeFromLocalDeck(_ id: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let index = playerDeck.firstIndex(where: { $0.id == id }) {
                playerDeck.remove(at: index)
            }
        }
    }
}

// The End Game Popup
// Extracted to keep the main code clean.
struct MatchSummaryView: View {
    let matches: [Movie]
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5).ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Match Summary")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                if matches.isEmpty {
                    Text("No matches this round.")
                        .foregroundStyle(.white.opacity(0.7))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(matches) { movie in
                                MatchRow(movie: movie)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 300)
                }

                Button(action: onClose) {
                    Text("Close")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.white, Color(white: 0.8)], startPoint: .top, endPoint: .bottom)
                        )
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                }
            }
            .padding(20)
            .background(.ultraThinMaterial) // Frosted glass effect
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
    }
}

// A Single Row in the Match List
struct MatchRow: View {
    let movie: Movie
    
    var body: some View {
        HStack(spacing: 12) {
            // AsyncImage downloads the poster
            // phase handles loading states
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath ?? "")")) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color(white: 0.15) // Grey placeholder while loading
                }
            }
            .frame(width: 50, height: 75)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(movie.title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

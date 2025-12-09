//
//  SplitScreenView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct SplitScreenView: View {
    let apiKey: String
    @StateObject private var gameManager = GameManager()

    var body: some View {
        ZStack {
            // BACKGROUND
            RadialGradient(
                gradient: Gradient(colors: [Color(white: 0.15), Color.black]),
                center: .center,
                startRadius: 5,
                endRadius: 600
            )
            .ignoresSafeArea()
            
            // Game
            VStack(spacing: 0) {
                // Player 2 (Top - Rotated)
                PlayerView(playerID: 2, gameManager: gameManager)
                    .rotationEffect(.degrees(180))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Center Glowing Divider
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, .white.opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 1)
                    .shadow(color: .white.opacity(0.5), radius: 5)
                
                // Player 1 (Bottom)
                PlayerView(playerID: 1, gameManager: gameManager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
        }
        .task {
            await gameManager.fetchPopularMovies(apiKey: apiKey)
        }
    }
}

struct PlayerView: View {
    let playerID: Int
    @ObservedObject var gameManager: GameManager
    
    // Performance Optimization: Only render the top 3 cards, when it loaded all the cards in at once it made the app unusable
    var visibleMovies: [Movie] {
        Array(gameManager.movies.prefix(3)) // come back to this!!!!!!!
    }
    
    var body: some View {
        ZStack {
            if gameManager.movies.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No more movies, come back next tomorrow!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
            } else {
                // Stack of Cards
                ZStack {
                    // ZStack layers views on top of each other in a 3D stack (Z-axis depth)
                    // I created an array from visibleMovies with index numbers, then reverse it
                    // Reversing makes the first movie (index 0) render last, appearing on top
                    // id: \.element.id tells swift to track each movie by its unique ID
                    ForEach(Array(visibleMovies.enumerated().reversed()), id: \.element.id) { index, movie in
                        // Check if this is the top card by seeing if its index is 0
                        // After reversing, index 0 is always the top card
                        let isTopCard = index == 0
                        // Create the individual movie card view with the current movie's data
                        MovieCardView(
                            movie: movie, // Pass the movie data to display
                            onSwipeRight: {
                                removeMovie(movie.id) // Remove this movie from the top of the deck
                            },
                            onSwipeLeft: {
                                removeMovie(movie.id) // Remove this movie from the top of the deck
                            }
                        )
                        // Adjust the size of the card based on whether it's on top
                        // Top card: 1.0, 100% size, cards behind: 0.9, 0.95, etc. (slightly smaller)
                        // This creates a cool depth effect
                        .scaleEffect(isTopCard ? 1.0 : 0.9 + (Double(index) * 0.05))
                        // Move cards vertically based on position
                        // Top card: 0 pixels offset, cards behind: 25 pixels down
                        // This makes background cards peek out from behind the top card
                        .offset(y: isTopCard ? 0 : 25)
                        // Adjust transparency of cards
                        // Top card: 1.0 (fully visible), background cards: 0.5 (semi-transparent/faded)
                        .opacity(isTopCard ? 1.0 : 0.5)
                        // Control which card can receive touch/tap input
                        // Only the top card (isTopCard = true) can be interacted with
                        // Background cards ignore touches
                        .allowsHitTesting(isTopCard)
                    }
                }
            }
        }
    }
    
    private func removeMovie(_ id: Int) {
        // Slight delay to allow the swipe animation to complete before data update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            gameManager.removeMovie(withID: id)
        }
    }
}

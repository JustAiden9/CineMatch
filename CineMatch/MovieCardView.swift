//
//  MovieCardView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    var onSwipeRight: (() -> Void)? = nil
    var onSwipeLeft: (() -> Void)? = nil
    
    @State private var offset: CGSize = .zero
    
    var posterURL: URL? {
        guard let path = movie.posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var body: some View {
        ZStack {
            // the actual image
            AsyncImage(url: posterURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // placeholder if api is down or no movies populate
                    ZStack {
                        Color(white: 0.1)
                        Image(systemName: "film")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
            }
            .frame(width: 230, height: 370) // Slightly larger for better touch targets
            .clipped()
            
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Text("Swipe to decide")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial) // The frosted glass effect
            }
        }
        .frame(width: 230, height: 370)
        .clipShape(RoundedRectangle(cornerRadius: 24)) // Smoother corners
        .overlay(
            // The Rim Light Border
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        // 4. Swipe Logic & Animation
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .scaleEffect(abs(offset.width) > 100 ? 1.05 : 1.0) // Slight pop when dragging far, abs allows our popeffect/drag to work both to the right and left, if we did not have abs it would only show to the right!
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation(.interactiveSpring()) {
                        offset = gesture.translation
                    }
                }
                .onEnded { gesture in
                    let swipeThreshold: CGFloat = 100 // makes it so that you can peek without 
                    if gesture.translation.width > swipeThreshold {
                        // SWIPE RIGHT (LIKE)
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset.width = 600
                            offset.height = 100
                        }
                        onSwipeRight?()
                    } else if gesture.translation.width < -swipeThreshold {
                        // SWIPE LEFT (DISLIKE)
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset.width = -600
                            offset.height = 100
                        }
                        onSwipeLeft?()
                        
                    } else {
                        // RESET
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            offset = .zero
                        }
                    }
                }
        )
    }
}

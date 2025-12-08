//
//  MovieCardView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct MovieCardView: View {
    var title: String = "Movie Card"
    var onYes: (() -> Void)? = nil
    var onNo: (() -> Void)? = nil
    @State private var dragAmount: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background rectangle
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.2))
                .shadow(radius: 4)
            
            // Title text
            Text(title)
                .font(.title2)
                .bold()
        }
        .frame(width: 260, height: 380)
        .offset(x: dragAmount.width, y: dragAmount.height)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Update position while dragging
                    dragAmount = gesture.translation
                }
                .onEnded { gesture in
                    // Check if swiped left or right
                    let swipeDistance = gesture.translation.width
                    
                    if swipeDistance < -100 {
                        // Swiped left = Yes
                        onYes?()
                    } else if swipeDistance > 100 {
                        // Swiped right = No
                        onNo?()
                    }
                    
                    // Reset position with animation
                    withAnimation(.spring()) {
                        dragAmount = .zero
                    }
                }
        )
    }
}

#Preview {
    MovieCardView(title: "Preview Movie")
}

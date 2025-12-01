//
//  MovieCardView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct MovieCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.secondary.opacity(0.2))
                .shadow(radius: 4)
            Text("Movie Card")
                .font(.title2)
                .bold()
        }
        .frame(width: 260, height: 380)
    }
}

#Preview {
    MovieCardView()
}

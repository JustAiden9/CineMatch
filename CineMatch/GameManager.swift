//
//  GameManager.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import Foundation
import Combine

struct Movie: Identifiable {
    let id: Int
    let title: String
}

class GameManager: ObservableObject {
    @Published var movies: [Movie] = [] // The stack of movies from TMDB
    var likes: [Int : Set<Int>] = [:]   // [MovieID : Set of PlayerID]
    
    func swipeRight(movieID: Int, playerID: Int) {
        // Logic to be implemented later
    }
}


//
//  GameManager.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import Combine
import Foundation

struct Movie: Identifiable, Codable {
    let id: Int  // Unique ID from TMDB
    let title: String  // Movie title
    let posterPath: String?  // URL path for the poster image like "/abc.jpg"
}
// Structure for the initial API response which wraps the list of movies
struct MovieResponse: Codable {
    let results: [Movie]
}
// GameManager handles all the game logic (state) and data fetching
class GameManager: ObservableObject {
    @Published var movies: [Movie] = []  // The deck of movies users see
    @Published var matches: [Movie] = []  // Movies both users liked
    // A 'Set' is like an Array, but it is much faster for looking up numbers
    // you can't like a movie twice
    private var player1Likes: Set<Int> = []
    private var player2Likes: Set<Int> = []
    func recordDecision(playerID: Int, movie: Movie, liked: Bool) {
        // Guard Statement: If they disliked it (swiped left), we stop here
        // I only care about tracking Likes for matches
        guard liked else { return }
        if playerID == 1 {
            // Add this movie ID to Player 1's list of likes
            player1Likes.insert(movie.id)
            // CHECK: Has Player 2 ALREADY liked this specific movie
            if player2Likes.contains(movie.id) {
                // if yes match
                createMatch(movie: movie)
            }
        } else {
            // Same logic for Player 2
            player2Likes.insert(movie.id)

            // Check if Player 1 has already liked it
            if player1Likes.contains(movie.id) {
                createMatch(movie: movie)
            }
        }
    }
    // function to add a movie to the match list
    private func createMatch(movie: Movie) {
        // Verify, this match is used to the UI this is used to prevent duplicates
        if !matches.contains(where: { $0.id == movie.id }) {
            matches.append(movie)
        }
    }
    // function to fetch all the name and photo data from TMDB
    func fetchPopularMovies(apiKey: String, language: String, page: Int) async {
        // Ensure the API key isn't empty before we try
        guard !apiKey.isEmpty else { return }
        // 1. Create the URL (This is based on the API Docs for TMDB)
        guard
            let url = URL(
                string:
                    "https://api.themoviedb.org/3/movie/popular?language=\(language)&page=\(page)"
            )
        else { return }
        // 2. Create the Request
        // We need a 'URLRequest' so we can use our API below
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // 3. Add Authentication
        // The API Key you use is a Bearer Token, which must go in the header, NOT the URL.
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKey)",
        ]
        do {
            // 4. Perform the Request
            // 'await' pauses this function here until the internet responds
            let (data, _) = try await URLSession.shared.data(for: request)
            // 5. Decode the JSON
            let decoder = JSONDecoder()
            // This automatically converts JSON keys like "poster_path" into somthing readable for swiftui
            // like "posterPath" (camelCase).
            decoder.keyDecodingStrategy = .convertFromSnakeCase  // this is the MOST helpfull thing ever, this allowed me to skip the translation/rewrite we would have needed to do!
            // Convert the raw data into our MovieResponse struct
            let movieResponse = try decoder.decode(
                MovieResponse.self,
                from: data
            )
            // 6. Update the UI
            // this jumps back to the MainActor to update @Published vars
            await MainActor.run {
                self.movies = movieResponse.results
            }
        } catch {
        }
    }

    // Removes a card from the deck so users don't see it again
    func removeMovie(withID id: Int) {
        // Find the index of the movie with this ID and remove it
        if let index = movies.firstIndex(where: { $0.id == id }) {
            movies.remove(at: index)
        }
    }
}

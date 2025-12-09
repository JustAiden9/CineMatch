//
//  GameManager.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import Foundation
import Combine

// Define a Movie struct that can be identified uniquely and converted to/from JSON
struct Movie: Identifiable, Codable {
    let id: Int                  // Unique identifier for the movie
    let title: String            // The movie's title/name
    let posterPath: String?      // Optional URL path to the movie poster image
    
    // Enum to map Swift property names to JSON keys from the API
    enum CodingKeys: String, CodingKey {
        case id                  // "id" in JSON maps to id property
        case title               // "title" in JSON maps to title property
        case posterPath = "poster_path"  // "poster_path" in JSON maps to posterPath property
    }
}

// Define the structure of the API response that contains an array of movies
struct MovieResponse: Codable {
    let results: [Movie]         // Array of Movie list from the API response
}

// GameManager handles all the game logic and data management
// ObservableObject: Allows SwiftUI views to watch for changes in this class
class GameManager: ObservableObject {
    // @Published makes SwiftUI automatically update views when this array changes
    // This array holds all the movies currently in the deck
    @Published var movies: [Movie] = []
    
    // Dictionary to store which movies each user has liked
    // Key: User ID (Int), Value: Set of liked movie IDs
    var likes: [Int : Set<Int>] = [:]
    
    // Base URL for constructing full image URLs from poster paths
    // TMDB requires combining this base URL with the poster path
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    // Asynchronous function to fetch popular movies from TMDB API
    func fetchPopularMovies(apiKey: String) async {
        // Exit early if no API key is provided (guard statement so that it does not try to continue and throw errors into the api calls)
        guard !apiKey.isEmpty else { return }

        // Try to create a URL object from the API endpoint string
        // If the creation fails, exit the function early
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular") else { return }
        
        // Create a URLComponents object to safely build the URL with query parameters
        // resolvingAgainstBaseURL: Ensures the URL is properly formed
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        // Define the query parameters to add to the URL
        // These specify we want English results from page 1
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: "en-US"),  // Request English language results
            URLQueryItem(name: "page", value: "2"),          // Request what ever page you want!
        ]
        
        // Add query items to the URL components
        // If queryItems already exist, append to them; otherwise, use our new ones
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        // Get the final complete URL with all query parameters
        // Exit if URL construction failed
        guard let finalURL = components.url else { return }
        
        // Create a URL request object with our constructed URL
        var request = URLRequest(url: finalURL)
        
        // Set the HTTP method to GET (retrieving data, not sending)
        request.httpMethod = "GET"
        
        // Set HTTP headers required by the TMDB API
        // accept: Tells the server we want JSON data back
        // Authorization: Provides our API key for authentication (Bearer token format)
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        // do-catch block code
        do {
            // Make the api request and wait for the response
            // data: The JSON data returned from the API
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Convert the JSON data into a MovieResponse object as defined above
            // JSONDecoder automatically maps JSON fields to our struct properties
            let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            
            // Switch to the main thread to update the UI
            // UI updates must happen on the main thread in iOS (learned this the hard way...)
            await MainActor.run {
                // Update the movies array with the fetched results
                // This triggers the @Published property, updating any listening views
                self.movies = movieResponse.results
            }
        } catch {
            // Silently ignore errors
        }
    }
    
    // Function to remove a specific movie from the deck
    // Called when a user swipes a card left or right
    // withID: External parameter name for clarity when calling the function
    // id: Internal parameter name used inside the function
    func removeMovie(withID id: Int) {
        // Find the index position of the movie with the matching ID
        // firstIndex returns the position if found, or nil if not found
        if let index = movies.firstIndex(where: { $0.id == id }) {
            // Remove the movie at that index position from the array
            // This automatically triggers UI updates due to @Published
            movies.remove(at: index)
        }
    }
}


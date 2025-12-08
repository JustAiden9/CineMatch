//
//  ApiTest.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI
import Foundation

struct ApiTest: View {
    @State private var apiKey: String = ""
    @State private var movies: [TrendingMovie] = []
    @State private var errorText: String? = nil
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("TMDB API Test")
                .font(.title)
                .bold()
                .padding(.top)

            TextField("Enter TMDB Bearer Token", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            Button("Fetch Trending Movies") {
                isLoading = true
                errorText = nil
                movies = []
                Task { await fetchTrendingMovies(bearerToken: apiKey) }
            }
            .buttonStyle(.borderedProminent)

            if isLoading { ProgressView() }

            if let errorText {
                ScrollView {
                    Text(errorText)
                        .padding()
                        .foregroundStyle(.primary)
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(movies) { movie in
                            HStack(alignment: .top, spacing: 12) {
                                AsyncImage(url: movie.posterURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ZStack {
                                            Color.gray.opacity(0.2)
                                            ProgressView()
                                        }
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        ZStack {
                                            Color.gray.opacity(0.2)
                                            Image(systemName: "photo")
                                                .foregroundStyle(.secondary)
                                        }
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 80, height: 120)
                                .clipped()
                                .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(movie.title)
                                        .font(.headline)
                                    if let date = movie.releaseDate, !date.isEmpty {
                                        Text(date)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.bottom)
    }
}

private struct TrendingResponse: Decodable {
    let page: Int
    let results: [RawTrendingMovie]
}

struct RawTrendingMovie: Decodable, Identifiable {
    let id: Int
    let title: String?
    let name: String?
    let poster_path: String?
    let release_date: String?
    let first_air_date: String?
}

struct TrendingMovie: Identifiable, Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
}

extension TrendingMovie {
    init(from raw: RawTrendingMovie) {
        self.id = raw.id
        self.title = raw.title ?? raw.name ?? "Untitled"
        self.posterPath = raw.poster_path
        self.releaseDate = raw.release_date ?? raw.first_air_date
    }
}

extension ApiTest {
    func fetchTrendingMovies(bearerToken: String) async {
        guard var components = URLComponents(string: "https://api.themoviedb.org/3/trending/movie/day") else {
            await MainActor.run { self.errorText = "Invalid URL"; self.isLoading = false }
            return
        }
        components.queryItems = [URLQueryItem(name: "language", value: "en-US")]
        guard let url = components.url else {
            await MainActor.run { self.errorText = "Invalid URL components"; self.isLoading = false }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? "<no body>"
                await MainActor.run {
                    self.errorText = "HTTP \(http.statusCode)\n\n\(body)"
                    self.isLoading = false
                }
                return
            }

            let decoder = JSONDecoder()
            // We keep snake_case keys as-is because RawTrendingMovie defines explicit names.
            let responseObject = try decoder.decode(TrendingResponse.self, from: data)
            let mapped = responseObject.results.map { TrendingMovie(from: $0) }

            await MainActor.run {
                self.movies = mapped
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorText = "Error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

#Preview {
    ApiTest()
}

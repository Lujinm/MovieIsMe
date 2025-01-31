//
//  GenreMoviesView.swift
//  MovieIsMe
//
//  Created by lujin mohammed on 27/07/1446 AH.
//

import SwiftUI

struct GenreMoviesView: View {
    let genre: String
    @State private var movies: [AirtableMovie] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(movies, id: \.id) { movie in
                    NavigationLink(destination: DetailsView(movie: movie)) {
                        AsyncImage(url: URL(string: movie.fields.poster)) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 150, height: 225)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(genre)
        .onAppear {
            Task {
                isLoading = true
                movies = await fetchMovies() ?? []
                movies = movies.filter { $0.fields.genre.contains(genre) }
                isLoading = false
            }
        }
    }

    private func fetchMovies() async -> [AirtableMovie]? {
        let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/movies")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let moviesResponse = try JSONDecoder().decode(AirtableMovieResponse.self, from: data)
                return moviesResponse.records
            } else {
                print("Error: \(response)")
                return nil
            }
        } catch {
            print("Error fetching movies: \(error)")
            return nil
        }
    }
}

#Preview {
    GenreMoviesView(genre: "Action")
}

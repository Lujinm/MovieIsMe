//
//  فثسف.swift
//  MovieIsMe
//
//  Created by lujin mohammed on 21/07/1446 AH.
//
import SwiftUI

struct DetailsView: View {
    let movie: AirtableMovie
    @State private var isBookmarked: Bool = false
    @State private var directors: [Director] = []
    @State private var actors: [Actor] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Poster Image
                AsyncImage(url: URL(string: movie.fields.poster)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 400)
                .cornerRadius(10)

                // Movie Title
                Text(movie.fields.name)
                    .font(.largeTitle)
                    .bold()

                // Movie Story
                Text(movie.fields.story)
                    .font(.body)
                    .foregroundColor(.gray)

                // Rating and Runtime
                HStack {
                    Text("Rating: \(movie.fields.rating)")
                        .font(.headline)
                    Spacer()
                    Text("Runtime: \(movie.fields.runtime)")
                        .font(.headline)
                }

                // IMDb Rating
                Text("IMDb Rating: \(String(format: "%.1f", movie.fields.IMDb_rating))")
                    .font(.headline)

                // Genres
                Text("Genres: \(movie.fields.genre.joined(separator: ", "))")
                    .font(.headline)

                // Languages
                Text("Languages: \(movie.fields.language.joined(separator: ", "))")
                    .font(.headline)

                // Divider
                Divider()
                    .padding(.vertical)

                // Directors Section
                Text("Director")
                    .font(.title2)
                    .bold()

                if !directors.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(directors, id: \.id) { director in
                                VStack {
                                    AsyncImage(url: URL(string: director.fields.image)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())

                                    Text(director.fields.name)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                } else {
                    Text("No directors found.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // Divider
                Divider()
                    .padding(.vertical)

                // Actors Section
                Text("Stars")
                    .font(.title2)
                    .bold()

                if !actors.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(actors, id: \.id) { actor in
                                VStack {
                                    AsyncImage(url: URL(string: actor.fields.image)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())

                                    Text(actor.fields.name)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                } else {
                    Text("No actors found.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .navigationTitle(movie.fields.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        toggleBookmark()
                    }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.yellow)
                    }

                    Button(action: {
                        shareMovie()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            checkIfBookmarked()
            fetchDirectorsAndActors()
        }
    }

    // MARK: - Helper Functions
    private func toggleBookmark() {
        var bookmarkedMovies = UserDefaults.standard.array(forKey: "bookmarkedMovies") as? [String] ?? []
        if isBookmarked {
            bookmarkedMovies.removeAll { $0 == movie.id }
        } else {
            bookmarkedMovies.append(movie.id)
        }
        UserDefaults.standard.set(bookmarkedMovies, forKey: "bookmarkedMovies")
        isBookmarked.toggle()
    }

    private func checkIfBookmarked() {
        let bookmarkedMovies = UserDefaults.standard.array(forKey: "bookmarkedMovies") as? [String] ?? []
        isBookmarked = bookmarkedMovies.contains(movie.id)
    }

    private func shareMovie() {
        let activityViewController = UIActivityViewController(
            activityItems: [movie.fields.name, movie.fields.poster],
            applicationActivities: nil
        )
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

    private func fetchDirectorsAndActors() {
        Task {
            isLoading = true
            directors = await fetchDirectors() ?? []
            actors = await fetchActors() ?? []
            isLoading = false
        }
    }

    private func fetchDirectors() async -> [Director]? {
        let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/directors")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let directorsResponse = try JSONDecoder().decode(DirectorResponse.self, from: data)
                return directorsResponse.records
            } else {
                print("Error: \(response)")
                return nil
            }
        } catch {
            print("Error fetching directors: \(error)")
            return nil
        }
    }

    private func fetchActors() async -> [Actor]? {
        let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/actors")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let actorsResponse = try JSONDecoder().decode(ActorResponse.self, from: data)
                return actorsResponse.records
            } else {
                print("Error: \(response)")
                return nil
            }
        } catch {
            print("Error fetching actors: \(error)")
            return nil
        }
    }
}

// MARK: - Data Models
struct AirtableMovieResponse2: Codable {
    let records: [AirtableMovie]
}

struct AirtableMovie2: Codable, Identifiable {
    let id: String
    let fields: AirtableMovieFields
}

struct AirtableMovieFields2: Codable {
    let name: String
    let rating: String
    let genre: [String]
    let poster: String
    let language: [String]
    let IMDb_rating: Double
    let runtime: String
    let story: String
}

struct DirectorResponse: Codable {
    let records: [Director]
}

struct Director: Codable, Identifiable {
    let id: String
    let fields: DirectorFields
}

struct DirectorFields: Codable {
    let name: String
    let image: String
}

struct ActorResponse: Codable {
    let records: [Actor]
}

struct Actor: Codable, Identifiable {
    let id: String
    let fields: ActorFields
}

struct ActorFields: Codable {
    let name: String
    let image: String
}

#Preview {
    DetailsView(movie: AirtableMovie(
        id: "1",
        fields: AirtableMovieFields(
            name: "The Dark Knight",
            rating: "PG-13",
            genre: ["Drama", "Crime", "Action", "Thriller"],
            poster: "https://cdn.shopify.com/s/files/1/0057/3728/3618/products/darkknight.building.24x36_500x749.jpg?v=1648745689",
            language: ["English"],
            IMDb_rating: 9.0,
            runtime: "2h 32m",
            story: "Set within a year after the events of Batman Begins (2005), Batman, Lieutenant James Gordon, and new District Attorney Harvey Dent begin to round up Gotham's criminals, until a sadistic criminal mastermind known as The Joker appears. The Joker creates chaos, forcing Batman to confront his beliefs and improve his technology. A love triangle develops between Bruce Wayne, Harvey Dent, and Rachel Dawes."
        )
    ))
}

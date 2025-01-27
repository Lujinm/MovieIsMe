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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: movie.fields.poster)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 400)
                .cornerRadius(10)

                Text(movie.fields.name)
                    .font(.largeTitle)
                    .bold()

                Text(movie.fields.story)
                    .font(.body)
                    .foregroundColor(.gray)

                HStack {
                    Text("Rating: \(movie.fields.rating)")
                        .font(.headline)
                    Spacer()
                    Text("Runtime: \(movie.fields.runtime)")
                        .font(.headline)
                }

                Text("IMDb Rating: \(String(format: "%.1f", movie.fields.IMDb_rating))")
                    .font(.headline)

                Text("Genres: \(movie.fields.genre.joined(separator: ", "))")
                    .font(.headline)

                Text("Languages: \(movie.fields.language.joined(separator: ", "))")
                    .font(.headline)
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
        }
    }

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

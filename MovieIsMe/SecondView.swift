//
//  SecondView.swift
//  MovieIsMe
//
//  Created by lujin mohammed on 20/07/1446 AH.
//


import SwiftUI

struct SecondView: View {
    @State var searchText: String = ""
    @State private var currentPage = 0
    @State private var movies: [AirtableMovie] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @Binding var isLoggedIn: Bool
    @Binding var email: String
    @Binding var pass: String

    let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if searchText.isEmpty {
                        highRatedSection
                        
                        sectionHeader(title: "Drama", genre: "Drama")
                        horizontalScrollContent(for: "Drama")
                        
                        sectionHeader(title: "Comedy", genre: "Comedy")
                        horizontalScrollContent(for: "Comedy")
                        
                        sectionHeader(title: "Action", genre: "Action")
                        horizontalScrollContent(for: "Action")
                        
                        sectionHeader(title: "Thriller", genre: "Thriller")
                        horizontalScrollContent(for: "Thriller")
                        
                        sectionHeader(title: "Crime", genre: "Crime")
                        horizontalScrollContent(for: "Crime")
                    } else {
                        // عرض نتائج البحث
                        let filteredMovies = filterMovies(searchText)
                        if filteredMovies.isEmpty {
                            Text("No results found for '\(searchText)'")
                                .foregroundColor(.white)
                                .padding()
                        } else {
                            ForEach(filteredMovies, id: \.id) { movie in
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
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Movies Center")
                .foregroundColor(.white)
                .searchable(text: $searchText, prompt: Text("Search for Movie name, actors ..."))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: ProfileView(isLoggedIn: $isLoggedIn, email: $email, pass: $pass)) {
                            Image(systemName: "person.circle")
                                .frame(width: 40, height: 30)
                                .background(.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            Task {
                isLoading = true
                movies = await fetchMovies() ?? []
                isLoading = false
            }
        }
    }

    // MARK: - High Rated Section
    private var highRatedSection: some View {
        VStack {
            Text("High Rated")
                .font(.system(size: 22))
                .bold()
                .padding(.trailing, 250.0)

            TabView(selection: $currentPage) {
                ForEach(topRatedMovies.indices, id: \.self) { index in
                    NavigationLink(destination: DetailsView(movie: topRatedMovies[index])) {
                        AsyncImage(url: URL(string: topRatedMovies[index].fields.poster)) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 355, height: 429)
                        .cornerRadius(10)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 429)

            HStack(spacing: 8) {
                ForEach(topRatedMovies.indices, id: \.self) { index in
                    let distance = abs(index - currentPage)
                    let size: CGFloat = {
                        switch distance {
                        case 0: return 12
                        case 1: return 10
                        case 2: return 8
                        default: return 6
                        }
                    }()
                    Circle()
                        .fill(index == currentPage ? Color.white : Color.gray.opacity(0.5))
                        .frame(width: size, height: size)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, genre: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 22))
                .bold()
            Spacer()
            NavigationLink(destination: GenreMoviesView(genre: genre)) {
                Text("Show more")
                    .font(.system(size: 14))
                    .bold()
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Horizontal Scroll Content
    private func horizontalScrollContent(for genre: String) -> some View {
        let filteredMovies = moviesByGenre(genre)

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(filteredMovies, id: \.id) { movie in
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
            .padding(.horizontal)
        }
    }

    // MARK: - Fetch Movies
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

    // MARK: - Filter Movies by Genre
    private func moviesByGenre(_ genre: String) -> [AirtableMovie] {
        return movies.filter { $0.fields.genre.contains(genre) }
    }

    // MARK: - Top Rated Movies
    private var topRatedMovies: [AirtableMovie] {
        return movies.sorted { $0.fields.IMDb_rating > $1.fields.IMDb_rating }
                     .prefix(7)
                     .map { $0 }
    }

    // MARK: - Filter Movies for Search
    private func filterMovies(_ searchText: String) -> [AirtableMovie] {
        if searchText.isEmpty {
            return movies
        } else {
            return movies.filter { movie in
                movie.fields.name.localizedCaseInsensitiveContains(searchText) ||
                movie.fields.story.localizedCaseInsensitiveContains(searchText) ||
                movie.fields.genre.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
}

// MARK: - Data Models
struct AirtableMovieResponse: Codable {
    let records: [AirtableMovie]
}

struct AirtableMovie: Codable {
    let id: String
    let fields: AirtableMovieFields
}

struct AirtableMovieFields: Codable {
    let name: String
    let rating: String
    let genre: [String]
    let poster: String
    let language: [String]
    let IMDb_rating: Double
    let runtime: String
    let story: String
}

#Preview {
    SecondView(isLoggedIn: .constant(true), email: .constant(""), pass: .constant(""))
}

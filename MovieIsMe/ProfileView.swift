//
//  ProfileView.swift
//  MovieIsMe
//
//  Created by lujin mohammed on 20/07/1446 AH.
//

import SwiftUI
import UIKit

struct ProfileView: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var user: AirtableUser? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var bookmarkedMovies: [AirtableMovie] = []
    @Binding var isLoggedIn: Bool
    @State private var profileImage: UIImage? = nil
       @Binding var email: String
       @Binding var pass: String

    let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let user = user {
                        NavigationLink(destination: EditProfileView(user: user, isLoggedIn: $isLoggedIn, email: .constant(""), pass: .constant(""))) {
                            VStack {
                                // عرض الصورة المحفوظة أو الصورة الافتراضية
                                if let savedImageData = UserDefaults.standard.data(forKey: "userProfileImage"),
                                   let savedImage = UIImage(data: savedImageData) {
                                    Image(uiImage: savedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                }

                                Text(user.fields.name)
                                    .font(.title)
                                    .foregroundColor(.white)

                                Text(user.fields.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.top, 40)
                        }
                    } else if isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        Text(errorMessage ?? "No user data found")
                            .foregroundColor(.red)
                            .padding(.top, 40)
                    }

                    Text("Saved Movies")
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(bookmarkedMovies, id: \.id) { movie in
                            NavigationLink(destination: DetailsView(movie: movie)) {
                                AsyncImage(url: URL(string: movie.fields.poster)) { image in
                                    image.resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 172, height: 237)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
            .navigationBarBackButtonHidden(false)
            .foregroundColor(.white)
            .onAppear {
                fetchUserData()
                fetchBookmarkedMovies()
            }
        }
    }

    func fetchUserData() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            errorMessage = "User ID not found."
            return
        }

        isLoading = true
        let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/users/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let user = try? JSONDecoder().decode(AirtableUser.self, from: data) {
                        self.user = user
                    } else {
                        errorMessage = "Error parsing user data."
                    }
                } else {
                    errorMessage = "Error fetching user data."
                }
            }
        }.resume()
    }

    func fetchBookmarkedMovies() {
        let bookmarkedMovieIds = UserDefaults.standard.array(forKey: "bookmarkedMovies") as? [String] ?? []
        var movies: [AirtableMovie] = []

        for id in bookmarkedMovieIds {
            let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/movies/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(token, forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let movie = try? JSONDecoder().decode(AirtableMovie.self, from: data) {
                        DispatchQueue.main.async {
                            movies.append(movie)
                            self.bookmarkedMovies = movies
                        }
                    }
                }
            }.resume()
        }
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true), email: .constant("example@example.com"), pass: .constant("password123"))
}


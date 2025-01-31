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
    @Environment(\.dismiss) private var dismiss

    let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let user = user {
                        NavigationLink(destination: EditProfileView(user: user, isLoggedIn: $isLoggedIn, email: .constant(""), pass: .constant(""))) {
                            HStack {
                                
                                if let savedImageData = UserDefaults.standard.data(forKey: "userProfileImage"),
                                   let savedImage = UIImage(data: savedImageData) {
                                    Image(uiImage: savedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .foregroundColor(.gray)
                                }
                                VStack{
                                    
                                    Text(user.fields.name)
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                    
                                    Text(user.fields.email)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }.padding(.trailing,160)
                            }
                            .padding()
                            .frame(width: 358, height: 80)
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
                        .font(.system(size: 22))
                        .bold()
                        .padding(.top, 30)
                        .padding(.trailing, 240)
                    
                    if bookmarkedMovies.isEmpty {
                        Image("backgrondempty")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 400)
                            .padding(.top, 20)
                    } else {
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
            }
            .navigationTitle("Profile")
            .navigationBarBackButtonHidden(true)
            .foregroundColor(.white)
            .onAppear {
                fetchUserData()
                fetchBookmarkedMovies()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundColor(.yellow)
                            Text("Back")
                                .foregroundColor(.yellow)
                        }
                        }
                }
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
    ProfileView(isLoggedIn: .constant(true), email: .constant("kaia@oconnor.com"), pass: .constant("kaia@oconnor.com"))
}

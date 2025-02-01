//
//  DetailsView.swift
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
   @State private var reviews: [Review] = []
   @State private var isLoading: Bool = false
   @State private var errorMessage: String? = nil
   @Environment(\.dismiss) private var dismiss

   let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

   var body: some View {
       ScrollView {
           GeometryReader { geometry in
               ZStack(alignment: .top) {
                   // صورة الفيلم
                   AsyncImage(url: URL(string: movie.fields.poster)) { image in
                       image.resizable()
                           .scaledToFill()
                   } placeholder: {
                       ProgressView()
                   }
                   .frame(width: geometry.size.width, height: geometry.size.height * 0.7) // 70% من ارتفاع الشاشة
                   .clipped()

                   // صورة الخلفية (detailsback)
                   Image("detailsback") // تأكد من أن الصورة موجودة في Assets.xcassets
                       .resizable()
                       .scaledToFill()
                       .frame(height: 450) // ارتفاع الصورة الخلفية
                       .offset(y: 50) // حرك الصورة الخلفية لأسفل
                       .clipped()

                   // الأزرار فوق الصورة
                   HStack {
                       // زر الرجوع
                       Button(action: {
                           dismiss()
                       }) {
                           Image(systemName: "arrow.left")
                               .foregroundColor(.yellow)
                               .frame(width: 32, height: 32)
                               .background(Color.black.opacity(0.6))
                               .clipShape(Circle())
                       }
                       .padding(.leading, 16)
                       .padding(.top, 50) // تباعد من الأعلى

                       Spacer()

                       // زر المشاركة
                       Button(action: {
                           shareMovie()
                       }) {
                           Image(systemName: "square.and.arrow.up")
                               .foregroundColor(.yellow)
                               .frame(width: 32, height: 32)
                               .background(Color.black.opacity(0.6))
                               .clipShape(Circle())
                       }
                       .padding(.top, 48)

                       // زر الحفظ
                       Button(action: {
                           toggleBookmark()
                       }) {
                           Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                               .foregroundColor(.yellow)
                               .frame(width: 32, height: 32)
                               .background(Color.black.opacity(0.6))
                               .clipShape(Circle())
                       }
                       .padding(.trailing, 16)
                       .padding(.top, 50) // تباعد من الأعلى
                   }

                   // محتوى الفيلم (اسم الفيلم والمعلومات الأخرى)
                   VStack(alignment: .leading, spacing: 16) {
                       Spacer() // يدفع المحتوى لأسفل داخل ZStack

                       // اسم الفيلم
                       Text(movie.fields.name)
                           .font(.largeTitle)
                           .bold()
                           .foregroundColor(.white) // لون النص أبيض
                           .padding(.horizontal)

                       // Duration and Language
                       HStack {
                           VStack {
                               Text("Duration")
                                   .font(.headline)
                                   .foregroundColor(.white)
                               Text("\(movie.fields.runtime)")
                                   .foregroundColor(.white.opacity(0.8))
                           }
                           Spacer()
                           VStack {
                               Text("Language")
                                   .font(.headline)
                                   .foregroundColor(.white)
                               Text(" \(movie.fields.language.joined(separator: ", "))")
                                   .foregroundColor(.white.opacity(0.8))
                           }
                       }
                       .padding(.horizontal)

                       // Genres and Age Rating
                       HStack {
                           VStack {
                               Text("Genres")
                                   .font(.headline)
                                   .foregroundColor(.white)
                               Text(" \(movie.fields.genre.joined(separator: ", "))")
                                   .foregroundColor(.white.opacity(0.8))
                           }
                           Spacer()
                           VStack {
                               Text("Age")
                                   .font(.headline)
                                   .foregroundColor(.white)
                               Text(" \(movie.fields.rating)")
                                   .foregroundColor(.white.opacity(0.8))
                           }
                       }
                       .padding(.horizontal)
                   }
                   .padding(.top, geometry.size.height * 0.1) // يرفع المحتوى إلى منتصف الصورة
               }
           }
           .frame(height: UIScreen.main.bounds.height * 0.6) // 70% من ارتفاع الشاشة

           // بقية المحتوى (القصة، المخرجين، الممثلين، التقييمات)
           VStack(alignment: .leading, spacing: 16) {
               // Movie Story
               Text("Story")
                   .font(.headline)
                   .padding(.horizontal)
               Text(movie.fields.story)
                   .foregroundColor(.gray)
                   .padding(.horizontal)

               // IMDb Rating
               VStack {
                   Text("IMDb Rating")
                       .font(.headline)
                   Text("\(String(format: "%.1f", movie.fields.IMDb_rating)) /10")
                       .foregroundColor(.gray)
               }
               .padding(.horizontal)

               Divider()
                   .padding(.vertical)

               // Directors Section
               Text("Director")
                   .font(.title2)
                   .bold()
                   .padding(.horizontal)

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
                   .padding(.horizontal)
               } else {
                   Text("No directors found.")
                       .font(.caption)
                       .foregroundColor(.gray)
                       .padding(.horizontal)
               }

               // Actors Section
               Text("Stars")
                   .font(.title2)
                   .bold()
                   .padding(.horizontal)

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
                   .padding(.horizontal)
               } else {
                   Text("No actors found.")
                       .font(.caption)
                       .foregroundColor(.gray)
                       .padding(.horizontal)
               }

               Divider()
                   .padding(.vertical)

               // Reviews Section
               Text("Rating & Reviews")
                   .font(.system(size: 18))
                   .bold()
                   .padding(.horizontal)

               if !reviews.isEmpty {
                   VStack(alignment: .leading, spacing: 5) {
                       // Average Rating
                       Text("\(String(format: "%.1f", calculateAverageRating()))")
                           .font(.system(size: 39, weight: .bold))
                           .foregroundColor(.gray)

                       Text("Out of 5")
                           .font(.system(size: 15))
                           .foregroundColor(.gray)

                       ScrollView(.horizontal, showsIndicators: false) {
                           HStack(spacing: 16) {
                               ForEach(reviews, id: \.id) { review in
                                   ReviewRow(review: review)
                                       .padding(.top, 25)
                               }
                           }
                           .padding(.horizontal)
                       }
                   }
               } else {
                   Text("No reviews found.")
                       .font(.caption)
                       .foregroundColor(.gray)
                       .padding(.horizontal)
               }
           }
       }
       .edgesIgnoringSafeArea(.top) // تجاهل Safe Area في الأعلى
       .navigationBarBackButtonHidden(true)
       .onAppear {
           checkIfBookmarked()
           fetchDirectorsAndActors()
           fetchReviews()
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

   private func fetchReviews() {
       Task {
           isLoading = true
           reviews = await fetchMovieReviews() ?? []
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

   private func fetchMovieReviews() async -> [Review]? {
       let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/reviews")!
       var request = URLRequest(url: url)
       request.httpMethod = "GET"
       request.addValue(token, forHTTPHeaderField: "Authorization")

       do {
           let (data, response) = try await URLSession.shared.data(for: request)
           if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
               let reviewsResponse = try JSONDecoder().decode(ReviewResponse.self, from: data)
               return reviewsResponse.records
           } else {
               print("Error: \(response)")
               return nil
           }
       } catch {
           print("Error fetching reviews: \(error)")
           return nil
       }
   }

   private func calculateAverageRating() -> Double {
       guard !reviews.isEmpty else { return 0.0 }
       let totalRating = reviews.reduce(0) { $0 + $1.fields.rate }
       return totalRating / Double(reviews.count)
   }
}

// MARK: - Review Row View
struct ReviewRow: View {
   let review: Review

   var body: some View {
       ZStack(alignment: .topLeading) {
           VStack(alignment: .leading, spacing: 8) {
               HStack {
                   // User Image
                   AsyncImage(url: URL(string: review.user?.fields.profile_image ?? "")) { image in
                       image.resizable()
                           .scaledToFill()
                   } placeholder: {
                       ProgressView()
                   }
                   .frame(width: 38, height: 38)
                   .clipShape(Circle())

                   // User Name and Rating
                   VStack(alignment: .leading, spacing: 4) {
                       Text(review.user?.fields.name ?? "Unknown User")
                           .font(.system(size: 13))
                           .bold()
                       HStack {
                           ForEach(0..<Int(review.fields.rate), id: \.self) { _ in
                               Image(systemName: "star.fill")
                                   .frame(width: 2, height: 9)
                                   .font(.system(size: 7.95))
                                   .foregroundColor(.yellow)
                           }
                       }
                   }
               }

               // Review Text
               Text(review.fields.review_text)
                   .font(.system(size: 13))
                   .foregroundColor(.primary)
                   .lineLimit(3)

               Spacer()

               if let createdTime = review.createdTime {
                   Text(formatDate(createdTime))
                       .font(.system(size: 10))
                       .foregroundColor(.gray)
                       .padding(.leading, 180)
               }
           }
           .padding()
           .frame(width: 305, height: 188)
           .background(Color(.systemGray6))
           .cornerRadius(8)
       }
   }

   private func formatDate(_ dateString: String) -> String {
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

       if let date = dateFormatter.date(from: dateString) {
           let outputFormatter = DateFormatter()
           outputFormatter.dateFormat = "MMMM d, yyyy"
           outputFormatter.locale = Locale(identifier: "en_US") // Ensure consistency
           return outputFormatter.string(from: date)
       }
       return dateString // Return original if formatting fails
   }
}

// MARK: - Data Models

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

struct ReviewResponse: Codable {
   let records: [Review]
}

struct Review: Codable, Identifiable {
   let id: String
   let createdTime: String?
   let fields: ReviewFields
   let user: User?
}

struct ReviewFields: Codable {
   let rate: Double
   let review_text: String
   let movie_id: String
   let user_id: String
}

struct UserResponse: Codable {
   let records: [User]
}

struct User: Codable, Identifiable {
   let id: String
   let fields: UserFields
}

struct UserFields: Codable {
   let profile_image: String
   let name: String
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

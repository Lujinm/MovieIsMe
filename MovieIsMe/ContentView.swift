//
//  ContentView.swift
//  MovieIsMe
//
//  Created by lujin mohammed on 19/07/1446 AH.
//
import SwiftUI

struct ContentView: View {
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @State var email: String = ""
    @State var pass: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var isPasswordVisible: Bool = false

    let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

    var body: some View {
        NavigationStack {
            ZStack {
                Image("firstbackground")
                    .resizable()
                    .frame(width: 402, height: 844)
                    .offset(x: 0, y: -180)

                Image("BlackOpicty")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    Spacer()

                    Text("Sign in ")
                        .font(.system(size: 40))
                        .bold()
                        .frame(width: 123, height: 48)
                        .foregroundColor(.white)

                    Text("You'll find what you're looking for in the ocean of movies")
                        .font(.system(size: 18))
                        .frame(width: 330, height: 50)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)

                    Text("Email")
                        .padding(.leastNormalMagnitude)
                        .font(.system(size: 18))
                        .foregroundColor(.white)

                    TextField("Enter your email", text: $email)
                        .padding(12)
                        .frame(width: 358, height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isEmailFocused ? .yellow : .clear, lineWidth: 2))
                        .accentColor(.yellow)
                        .foregroundColor(.white)
                        .focused($isEmailFocused)
                        .padding(.bottom, 24)

                    Text("Password")
                        .padding(.leastNormalMagnitude)
                        .font(.system(size: 18))
                        .foregroundColor(.white)

                    ZStack {
                        HStack {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $pass)
                            } else {
                                SecureField("Enter your password", text: $pass)
                            }

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .frame(width: 358, height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isPasswordFocused ? .red : .clear, lineWidth: 2))
                        .accentColor(.red)
                        .foregroundColor(pass.isEmpty ? .red : .white)
                        .focused($isPasswordFocused)
                        .padding(.bottom, 30)
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                            .padding(.top, -25)
                    }

                    Button(action: {
                        Task {
                            await signIn()
                        }
                    }) {
                        Text("Sign in ")
                            .bold()
                            .foregroundColor((!email.isEmpty && !pass.isEmpty) ? .black : .gray)
                            .frame(width: 358, height: 44)
                            .background((!email.isEmpty && !pass.isEmpty) ? Color.yellow : Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .padding(.bottom, 70)
                    }
                    .disabled(isLoading || email.isEmpty || pass.isEmpty)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.top, 20)
                    }
                }
                .keyboardAvoiding()
                .navigationDestination(isPresented: $isLoggedIn) {
                    SecondView(isLoggedIn: $isLoggedIn, email: $email, pass: $pass)
                }
            }
        }
    }

    func signIn() async {
        guard !email.isEmpty, !pass.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        isLoading = true
        let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let users = try? JSONDecoder().decode(AirtableResponse.self, from: data) {
                    if let user = users.records.first(where: { $0.fields.email.lowercased() == email.lowercased() && $0.fields.password == pass }) {
                        DispatchQueue.main.async {
                            self.isLoggedIn = true
                            self.errorMessage = nil
                            UserDefaults.standard.set(user.id, forKey: "userId")
                        }
                        print("Login Successful for \(user.fields.name)")
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Invalid password"
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error parsing user data."
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Error connecting to the server."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "An error occurred. Please try again."
            }
        }

        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}

struct AirtableResponse: Codable {
    let records: [AirtableUser]
}

struct AirtableUser: Codable {
    let id: String
    let fields: AirtableUserFields
}

struct AirtableUserFields: Codable {
    let email: String
    let password: String
    let name: String
    let profile_image: String
}

#Preview {
    ContentView()
}

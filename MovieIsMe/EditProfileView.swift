//
//  EditProfileView.swift
//  MovieIsMe
//
//  Created by lujin mohammed on 21/07/1446 AH.
//

import SwiftUI
import UIKit

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isLoggedIn: Bool
    @Binding var email: String
    @Binding var pass: String
    @State private var firstName: String
    @State private var lastName: String
    @State private var isEditing: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false

    let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"
    let user: AirtableUser

    let defaultProfileImage = UIImage(systemName: "person.circle.fill")!

    init(user: AirtableUser, isLoggedIn: Binding<Bool>, email: Binding<String>, pass: Binding<String>) {
        let nameComponents = user.fields.name.components(separatedBy: " ")
        self._firstName = State(initialValue: nameComponents.first ?? "")
        self._lastName = State(initialValue: nameComponents.last ?? "")
        self.user = user
        self._isLoggedIn = isLoggedIn
        self._email = email
        self._pass = pass

        if let savedImageData = UserDefaults.standard.data(forKey: "userProfileImage"),
           let savedImage = UIImage(data: savedImageData) {
            self._selectedImage = State(initialValue: savedImage)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // الصورة
                Image(uiImage: selectedImage ?? defaultProfileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isEditing ? Color.yellow : Color.gray, lineWidth: 2)
                    )
                    .onTapGesture {
                        if isEditing {
                            showImagePicker = true
                        }
                    }

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("First name")
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    .frame(height: 40)
                    TextField("First name", text: $firstName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .disabled(!isEditing) // منع التعديل إذا لم يكن وضع التحرير مفعلًا

                    Divider()

                    HStack {
                        Text("Last name")
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    .frame(height: 40)
                    TextField("Last name", text: $lastName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .disabled(!isEditing) // منع التعديل إذا لم يكن وضع التحرير مفعلًا
                }
                .frame(width: 358, height: 200)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.top, 20)

                Spacer()

                Button(action: {
                    UserDefaults.standard.removeObject(forKey: "userId")
                    UserDefaults.standard.removeObject(forKey: "userProfileImage") // حذف الصورة المحفوظة
                    email = ""
                    pass = ""
                    isLoggedIn = false
                    
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sign Out")
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 358, height: 44)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)
                
            }
            .navigationTitle(isEditing ? "Edit Profile" : "Profile Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isEditing {
                            updateProfile()
                        }
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Save" : "Edit")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }

    func updateProfile() {
        isLoading = true
        let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/users/\(user.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let updatedName = "\(firstName) \(lastName)"
        let body: [String: Any] = [
            "fields": [
                "name": updatedName
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Profile updated successfully")

                    if let selectedImage = selectedImage,
                       let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
                        UserDefaults.standard.set(imageData, forKey: "userProfileImage")
                    }
                } else {
                    errorMessage = "Error updating profile."
                }
            }
        }.resume()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    EditProfileView(user: AirtableUser(id: "recPMaNVKM6yYZFIl", fields: AirtableUserFields(email: "kaia@oconnor.com", password: "kaia@oconnor.com", name: "Kaia Oconnor", profile_image: "https://source.unsplash.com/200x200/?person")), isLoggedIn: .constant(true), email: .constant(""), pass: .constant(""))
}

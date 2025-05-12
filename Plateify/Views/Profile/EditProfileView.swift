import SwiftUI
import PhotosUI
import Photos
import UIKit

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    let user: User
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var username: String
    @State private var plateNumber: String
    @State private var bio: String
    @State private var profileImage: Image?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var imageData: Data?
    @State private var showImagePicker = false
    
    init(user: User) {
        self.user = user
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName)
        _username = State(initialValue: user.username)
        _plateNumber = State(initialValue: user.plateNumbers.first ?? "")
        _bio = State(initialValue: user.bio ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Profile Image
                    HStack {
                        Spacer()
                        VStack {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            }
                            
                            Button {
                                showImagePicker = true
                            } label: {
                                Text("Change Photo")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section("Personal Information") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prenume")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("First Name", text: $firstName)
                            .textContentType(.givenName)
                            .autocorrectionDisabled()
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nume")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Last Name", text: $lastName)
                            .textContentType(.familyName)
                            .autocorrectionDisabled()
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nume utilizator")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("@")
                                .foregroundColor(.secondary)
                            TextField("Nume utilizator", text: $username)
                                .autocorrectionDisabled()
                        }
                    }
                }
                
                Section("About") {
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Button(action: saveProfile) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save Changes")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(imageData: $imageData, profileImage: $profileImage)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        Task {
            do {
                var updatedUser = user
                updatedUser.firstName = firstName
                updatedUser.lastName = lastName
                updatedUser.username = username
                updatedUser.plateNumbers = plateNumber.isEmpty ? [] : [plateNumber]
                updatedUser.bio = bio.isEmpty ? nil : bio
                
                // If there's a new image, upload it
                if let imageData = imageData {
                    if let imageURL = await viewModel.uploadProfileImage(imageData, userId: user.id) {
                        updatedUser.profileImageURL = imageURL.absoluteString
                    } else {
                        throw NSError(domain: "EditProfileView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"])
                    }
                }
                
                // Update the user in Firestore
                await viewModel.updateProfile(updatedUser)
                
                // Update the local user in AuthenticationViewModel
                await MainActor.run {
                    authViewModel.user = updatedUser
                }
                
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isLoading = false
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Binding var profileImage: Image?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                if let data = image.jpegData(compressionQuality: 0.7) {
                    parent.imageData = data
                    parent.profileImage = Image(uiImage: image)
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    EditProfileView(user: TestData.testUser)
}

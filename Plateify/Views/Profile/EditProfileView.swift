import SwiftUI
import PhotosUI
import UIKit

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AuthenticationViewModel

    private let sexOptions = ["Masculin", "Feminin", "Altul"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            if let image = viewModel.profileImage {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let urlString = viewModel.profileImageURL,
                                      let url = URL(string: urlString) {
                                AsyncImage(url: url) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }

                            Button("Schimbă poza") {
                                viewModel.showImagePicker = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                }

                Section("Informații personale") {
                    TextField("Prenume", text: $viewModel.firstName)
                        .textContentType(.givenName)
                    TextField("Nume", text: $viewModel.lastName)
                        .textContentType(.familyName)
                    TextField("Nume utilizator", text: $viewModel.username)
                        .autocorrectionDisabled()
                    Picker("Sex", selection: $viewModel.sex) {
                        ForEach(sexOptions, id: \.self) { sex in
                            Text(sex)
                        }
                    }
                    DatePicker("Data nașterii", selection: $viewModel.birthdate, displayedComponents: .date)
                }

                Section("Despre mine") {
                    TextEditor(text: $viewModel.bio)
                        .frame(height: 100)
                }

                Section {
                    Button(action: saveChanges) {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Salvează modificările")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(
                    imageData: $viewModel.imageData,
                    profileImage: $viewModel.profileImage
                )
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }

    private func saveChanges() {
        Task {
            await viewModel.saveProfile()
            if viewModel.error == nil {
                dismiss()
            }
        }
    }
}


// MARK: - Preview
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let user = TestData.user
        let authVM = AuthenticationViewModel(previewUser: user)
        return EditProfileView(viewModel: authVM)
            .preferredColorScheme(.light)
    }
}


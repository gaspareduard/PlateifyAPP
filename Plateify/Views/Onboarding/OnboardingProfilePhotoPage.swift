import SwiftUI
import PhotosUI

struct OnboardingProfilePhotoPage: View {
    @Binding var mainPhoto: Image?
    @Binding var mainPhotoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            Text("Adaugă o Poză la Profil")
                .font(.title)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            Text("Asociazā-ți numarul de inmatriculare cu o poza de profil care te defineste.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
            // Main photo
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(18)
                    if let mainPhoto = mainPhoto {
                        mainPhoto
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 32, height: 28)
                                .foregroundColor(.blue)
                            Text("Fotografie de profil")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Apasă pentru a încărca")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(height: 180)
            }
            .onChange(of: selectedPhotoItem) { newItem in
                if let newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            mainPhoto = Image(uiImage: uiImage)
                            mainPhotoData = data
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            // Guidelines
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Ghid pentru poze de profil")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            Spacer()
        }
    }
}
//
//  UserProfileView.swift
//  Plateify
//
//  Created by Eduard Gaspar on 15.05.2025.
//


import SwiftUI
extension DiscoverView{
    struct DiscoverDetailedView: View {
        let user: NearbyUser
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        if let imageURL = user.profileImageURL,
                           let url = URL(string: imageURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 150, height: 150)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let age = user.age {
                                Text("\(age) ani")
                                    .font(.title3)
                            }
                            
                            if let bio = user.bio {
                                Text(bio)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            if let plate = user.plateNumbers.first {
                                NumberPlateDisplayView(plate: plate)
                                    .padding(.top)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Profil \(user.name)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading){
                        Button {
                            dismiss()
                        }label: {
                            Image(systemName: "chevron.down")
                                .imageScale(.large)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    // Create a sample NearbyUser for preview
    let previewUser = NearbyUser(
        id: "preview-1",
        profileImageURL: "https://randomuser.me/api/portraits/women/43.jpg",
        plateNumbers: ["B 123 XYZ"],
        firstName: "Ana",
        age: 28,
        bio: "Love traveling and meeting new people. Passionate about cars and road trips. Always up for new adventures! 🚗✨",
        latitude: 44.4268,
        longitude: 26.1025
    )
    
    DiscoverView.DiscoverDetailedView(user: previewUser)
        
}


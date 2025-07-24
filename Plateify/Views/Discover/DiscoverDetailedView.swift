//
//  UserProfileView.swift
//  Plateify
//
//  Created by Eduard Gaspar on 15.05.2025.
//


import SwiftUI
extension DiscoverView{
    struct UserProfileView: View {
        let user: NearbyUser
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    if let imageURL = user.profileImageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
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
        }
    }
}


// MARK: - Preview
#Preview{
    DiscoverView.UserProfileView(user: TestData.nearbyUser1)
        }



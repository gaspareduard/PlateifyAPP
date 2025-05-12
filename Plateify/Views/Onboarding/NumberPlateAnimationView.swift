import SwiftUI
import PhotosUI

struct NumberPlateAnimationView: View {
    var body: some View {
       RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .frame(width: 180, height: 48)
            .overlay(
                HStack(spacing: 6) {
                    Text("RO")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(red: 0, green: 0, blue: 139/255))
                        .cornerRadius(2)
                    Text("B 123 ABC")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            ).shadow(radius: 4)
            
    }
}
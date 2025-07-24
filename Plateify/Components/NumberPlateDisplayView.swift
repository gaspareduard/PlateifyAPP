import SwiftUI

struct NumberPlateDisplayView: View {
    let plate: String
    var body: some View {
        HStack(spacing: 8) {
            // RO blue section
            Text("RO")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color(red: 0, green: 0, blue: 139/255))
                .cornerRadius(4)
            // Plate number
            Text(plate)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.trailing, 8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color(.systemGray4).opacity(0.08), radius: 1, x: 0, y: 1)
    }
} 

#Preview {
    NumberPlateDisplayView(plate: "B123ABC")
}

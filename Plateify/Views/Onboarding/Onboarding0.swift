import SwiftUI
import PhotosUI
extension OnboardingCarouselView{
    struct OnboardingWelcomePage: View {
        @Binding var currentPage: Int
        var body: some View {
            VStack(spacing: 0) {
                
                Spacer()
                
                Image("Carousel1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300) // Adjust width as needed
                
                
                
                Text("Bun venit la Plateify!")
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.top,32)
                    .padding(.bottom,8)
                
                Text("Transformă întâlnirile din trafic în conexiuni reale. Descoperă și conversează cu oameni prin intermediul numerelor de înmatriculare.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                
                Spacer()
                
                NumberPlateAnimationView()
                    .padding(.bottom,50)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "shield.fill")
                        .foregroundColor(Color.blue)
                        .font(.caption)
                    Text("Confidențialitatea și siguranța ta sunt prioritatea noastră")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal)
        }
    }
}

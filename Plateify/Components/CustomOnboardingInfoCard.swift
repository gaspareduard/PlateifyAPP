import SwiftUI

struct OnboardingInfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 20, weight: .medium))
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingInfoCard(
            icon: "car.fill",
            iconColor: .blue,
            title: "Primul număr de înmatriculare",
            subtitle: "Ulterior poți introduce mai multe numere de înmatriculare"
        )
        .padding(.horizontal)

        OnboardingInfoCard(
            icon: "person.fill",
            iconColor: .green,
            title: "Profilul tău",
            subtitle: "Completează profilul pentru a primi recomandări mai bune"
        )
        .padding(.horizontal)
    }
}

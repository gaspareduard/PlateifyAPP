import SwiftUI

struct PlateSearchField: View {
    @Binding var text: String
    var onSubmit: () -> Void
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.blue)
            TextField("Introdu numărul de înmatriculare", text: $text, onCommit: onSubmit)
                .font(.body)
                .foregroundColor(.primary)
                .disableAutocorrection(true)
                .autocapitalization(.allCharacters)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(.systemGray4).opacity(0.15), radius: 2, x: 0, y: 1)
    }
} 
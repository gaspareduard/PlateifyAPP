import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var showProfileResult = false
    @State private var selectedPlate: String? = nil
    
    // Add state for error message
    @State private var errorMessage: String? = nil
    
    // Add state for loading indicator
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack() {
                VStack(spacing: 0) {
                    
                    Header()
                    
                    // Search field card
                    
                    SearchBarNumberPlate(
                        searchText: $searchText,
                        selectedPlate: $selectedPlate,
                        showProfileResult: $showProfileResult,
                        isSearchFieldFocused: $isSearchFieldFocused,
                        isLoading: $isLoading,
                        errorMessage: $errorMessage
                    )
                    
                    // Scan and Import buttons
                    HStack(spacing: 16) {
                        SearchActionButton(
                            title: "Scanează",
                            icon: "camera.fill",
                            background: Color.blue,
                            foreground: .white,
                            filled: true
                        ) {}
                        SearchActionButton(
                            title: "Importă poză",
                            icon: "photo.on.rectangle",
                            background: Color.blue.opacity(0.08),
                            foreground: .blue,
                            filled: false
                        ) {}
                    }
                    .padding(.horizontal)
                    .padding(.top, 18)
                    
                    Spacer(minLength: 32)
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            // Update navigation destination to pass the found user data
            .navigationDestination(isPresented: $showProfileResult) {
                if let user = SearchViewModel.shared.user {
                    SearchProfileResult(user: user)
                } else {
                    Text("No user found")
                }
            }
            // Add error message popup
            .alert(item: Binding<AlertItem?>(
                get: { errorMessage.map { AlertItem(message: $0) } },
                set: { errorMessage = $0?.message }
            )) { alert in
                Alert(title: Text("Eroare"), message: Text(alert.message), dismissButton: .default(Text("OK")))
            }
            // Add loading indicator
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                }
            }
            // Reset user when navigating back
            .onDisappear {
                SearchViewModel.shared.user = nil
            }
        }
    }
}

// MARK: - Reusable Components

struct SearchActionButton: View {
    let title: String
    let icon: String
    let background: Color
    let foreground: Color
    var filled: Bool = true
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(foreground)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(foreground)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(filled ? background : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(filled ? Color.clear : background, lineWidth: filled ? 0 : 2)
            )
            .cornerRadius(16)
        }
    }
}


struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                
                if let plateNumber = user.plateNumbers.first {
                    Text(plateNumber)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button {
                // Add friend request functionality
            } label: {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

// Commenting out the SearchBar and ErrorView structs
/*
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search by plate number...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding()
        }
    }
}
*/

// Add AlertItem struct for error handling
struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}



#Preview {
    SearchView()
} 


extension SearchView{
    struct Header: View {
        var body: some View {
            VStack(spacing:0){
                // Title and subtitle
                Text("Găsește-ți prietenii")
                    .font(.title)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .padding(.top, 28)
                Text("Alege metoda preferată de căutare")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                
                // Illustration
                Image("Search1")
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    struct SearchBarNumberPlate: View {
            @Binding var searchText: String
            @Binding var selectedPlate: String?
            @Binding var showProfileResult: Bool
            @FocusState.Binding var isSearchFieldFocused: Bool
            @Binding var isLoading: Bool
            @Binding var errorMessage: String?
        
        var body: some View {
            HStack {
                TextField("B123ABC", text: $searchText, onCommit: {
                    if !searchText.isEmpty {
                        selectedPlate = searchText
                        showProfileResult = true
                    }
                })
                .font(.title3)
                .foregroundColor(.black)
                .disableAutocorrection(true)
                .autocapitalization(.allCharacters)
                .focused($isSearchFieldFocused)
                
                Button(action: {
                    if !searchText.isEmpty {
                        isLoading = true
                        SearchViewModel.shared.searchUser(byPlate: searchText) { user, error in
                            isLoading = false
                            if let user = user {
                                selectedPlate = searchText
                                showProfileResult = true
                            } else if let error = error {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color(.systemGray4).opacity(0.90), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    
}


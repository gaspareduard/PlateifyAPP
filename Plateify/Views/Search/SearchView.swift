import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var ChatVM: ChatListViewModel
    @ObservedObject var FriendVM: FriendViewModel
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var showProfileResult = false
    @State private var selectedPlate: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 0) {
                    Header()

                    // Search field card
                    SearchBarNumberPlate(
                        searchText: $searchText,
                        selectedPlate: $selectedPlate,
                        showProfileResult: $showProfileResult,
                        isSearchFieldFocused: $isSearchFieldFocused
                    ) {
                        Task {
                            await viewModel.searchPlate(searchText)
                            if !viewModel.searchResults.isEmpty {
                                selectedPlate = searchText
                                showProfileResult = true
                            }
                        }
                    }

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
            .navigationDestination(isPresented: $showProfileResult) {
                if let searchedUser = viewModel.searchResults.first {
                    SearchProfileResult(
                        searchedUser: searchedUser,
                        chatVM: ChatVM,
                        friendVM: FriendVM
                        )
                } else {
                    Text("No user found")
                }
            }
            .alert("Eroare", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                }
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
    let user: UserSummary
    let onConnect: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill").resizable()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                if let plate = user.primaryPlate {
                    Text(plate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: onConnect) {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

extension SearchView {
    struct Header: View {
        var body: some View {
            VStack(spacing: 0) {
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
        let onSearch: () -> Void

        var body: some View {
            HStack {
                TextField("B123ABC", text: $searchText)
                    .font(.title3)
                    .foregroundColor(.black)
                    .disableAutocorrection(true)
                    .autocapitalization(.allCharacters)
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        onSearch()
                    }

                Button(action: onSearch) {
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

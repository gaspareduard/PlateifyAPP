import SwiftUI

struct SearchView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var searchText = ""
    @State private var showingResults = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                SearchBar(text: $searchText, onSubmit: performSearch)
                    .padding()
                
                if searchViewModel.isLoading {
                    ProgressView()
                } else if let error = searchViewModel.error {
                    ErrorView(error: error)
                } else if showingResults {
                    SearchResultsView(results: searchViewModel.searchResults)
                } else {
                    RecentSearchesView(searches: searchViewModel.recentSearches)
                }
                
                Spacer()
            }
            .navigationTitle("Search Plates")
        }
    }
    
    private func performSearch() {
        Task {
            await searchViewModel.searchPlate(searchText)
            showingResults = true
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Enter plate number...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit(onSubmit)
            
            Button(action: onSubmit) {
                Text("Search")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct SearchResultsView: View {
    let results: [User]
    
    var body: some View {
        List(results) { user in
            NavigationLink(destination: UserProfileView(user: user)) {
                UserRow(user: user)
            }
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
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                if let plateNumber = user.plateNumber {
                    Text(plateNumber)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct RecentSearchesView: View {
    let searches: [Search]
    
    var body: some View {
        List {
            Section(header: Text("Recent Searches")) {
                ForEach(searches) { search in
                    HStack {
                        Text(search.plateNumber)
                            .font(.headline)
                        Spacer()
                        Text(search.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    SearchView()
} 
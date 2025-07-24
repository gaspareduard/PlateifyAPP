import SwiftUI

struct EditNumberPlatesView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authVM: AuthenticationViewModel
    
    @State private var showAddSheet = false
    @State private var newPlate = ""
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(authVM.plateNumbers, id: \.self) { plate in
                        HStack(spacing: 16) {
                            NumberPlateView(plate: plate)
                                .frame(height: 56)
                                .padding(.vertical, 4)
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                // Will be implemented later
                                print("DEBUG: Delete plate tapped for: \(plate)")
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                } header: {
                    Text("Vehiculele salvate")
                }
                
                Section {
                    Button {
                        showAddSheet = true
                        print("DEBUG: Add new plate tapped")
                    } label: {
                        Label("Add New Plate", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Number Plates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddPlateSheet(newPlate: $newPlate, onAdd: { plate in
                    if !plate.isEmpty {
                        authVM.plateNumbers.append(plate)
                        print("DEBUG: Added new plate: \(plate)")
                    }
                    showAddSheet = false
                    newPlate = ""
                }, onCancel: {
                    showAddSheet = false
                    newPlate = ""
                })
            }
        }
    }
}

// MARK: - NumberPlateView Component
extension EditNumberPlatesView {
    struct NumberPlateView: View {
        let plate: String
        
        // Helper to parse the plate string
        private var parsed: (county: String, number: String, letters: String) {
            // Romanian plates: 1-2 letters, 2-3 digits, 3 letters
            // Example: B123ABC, TM33BEC, B73GGG
            let lettersSet = CharacterSet.letters
            let digitsSet = CharacterSet.decimalDigits
            var county = ""
            var number = ""
            var letters = ""
            var i = plate.startIndex
            // County: 1 or 2 letters
            while i < plate.endIndex, String(plate[i]).rangeOfCharacter(from: lettersSet) != nil {
                county.append(plate[i])
                i = plate.index(after: i)
                if county.count == 2 { break }
            }
            // Number: 2 or 3 digits
            while i < plate.endIndex, String(plate[i]).rangeOfCharacter(from: digitsSet) != nil {
                number.append(plate[i])
                i = plate.index(after: i)
                if number.count == 3 { break }
            }
            // Letters: rest
            while i < plate.endIndex, String(plate[i]).rangeOfCharacter(from: lettersSet) != nil {
                letters.append(plate[i])
                i = plate.index(after: i)
            }
            return (county, number, letters)
        }
        
        var body: some View {
            let parsedPlate = parsed
            HStack(spacing: 0) {
                
                // EU Section
                VStack(spacing: 3) {
                    EuropeanEmblemView()
                        .frame(width: 18, height: 18)
                    Text("RO")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(.white)
                }
                .frame(width: 45, height: 48)
                .background(Color(red: 0, green: 0, blue: 139 / 255))
                .cornerRadius(6, corners: [.topLeft, .bottomLeft])
                
                HStack(spacing: 8) {
                    Text(parsedPlate.county)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    Text(parsedPlate.number)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    Text(parsedPlate.letters)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 12)
                .frame(maxHeight: .infinity)
                .background(Color.white)
            }
            .frame(height: 48)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 4)
            )
            .cornerRadius(8)
        }
    }
    
    }


// MARK: - AddPlateSheet
extension EditNumberPlatesView {
    struct AddPlateSheet: View {
        @Binding var newPlate: String
        var onAdd: (String) -> Void
        var onCancel: () -> Void
        
        var body: some View {
            NavigationStack {
                VStack(spacing: 24) {
                    Text("Add New Number Plate")
                        .font(.title2.bold())
                        .padding(.top)
                    NumberPlateInputView(plateNumber: $newPlate)
                        .padding(.horizontal)
                    Spacer()
                    Button(action: {
                        onAdd(newPlate)
                    }) {
                        Text("Add Plate")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(newPlate.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(newPlate.isEmpty)
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            onCancel()
                        }
                    }
                }
            }
        }
    }
}



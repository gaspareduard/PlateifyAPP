import SwiftUI

struct NumberPlateInputView: View {
    let counties = ["AB", "AR", "AG", "B", "BC", "BH", "BN", "BR", "BT", "BV", "BZ", "CS", "CL", "CJ", "CT", "CV", "DB", "DJ", "GL", "GR", "GJ", "HR", "HD", "IL", "IS", "IF", "MM", "MH", "MS", "NT", "OT", "PH", "SM", "SJ", "SB", "SV", "TR", "TM", "TL", "VS", "VL", "VN"]
    @Binding var plateNumber: String
    @State private var selectedCounty: String = "TM"
    @State private var number: String = ""
    @State private var letters: String = ""

    var body: some View {
        HStack(spacing: 0) {
            // EU Section
            VStack(spacing: 6) {
                EuropeanEmblemView()
                    .frame(width: 22, height: 22)
                Text("RO")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 45, height: 80)
            .background(Color(red: 0, green: 0, blue: 139 / 255))
            .cornerRadius(6, corners: [.topLeft, .bottomLeft])

            // Plate Input Section
            HStack(spacing: 8) {
                // County
                Menu {
                    ForEach(counties, id: \.self) { county in
                        Button {
                            selectedCounty = county
                        } label: {
                            Text(county)
                                .font(.headline)
                        }
                    }
                } label: {
                    HStack(spacing: 2) {
                        Text(selectedCounty)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
                .frame(width: 60)

                // Numbers
                TextField("123", text: $number)
                    .keyboardType(.numberPad)
                    .frame(width: 55)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .onChange(of: number) { newValue in
                        number = String(newValue.prefix(3).filter { $0.isNumber })
                        updatePlate()
                    }

                // Letters
                TextField("ABC", text: $letters)
                    .autocapitalization(.allCharacters)
                    .frame(width: 75)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .onChange(of: letters) { newValue in
                        letters = String(newValue.prefix(3).uppercased().filter { $0.isLetter })
                        updatePlate()
                    }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 80)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 4)
        )
        .cornerRadius(8)
        .onChange(of: selectedCounty) { _ in updatePlate() }
        .onAppear {
            if !plateNumber.isEmpty {
                let comps = plateNumber.components(separatedBy: " ")
                if comps.count == 3 {
                    selectedCounty = comps[1]
                    let numLet = comps[2]
                    number = String(numLet.prefix { $0.isNumber })
                    letters = String(numLet.suffix(3))
                }
            }
            updatePlate()
        }
    }

    private func updatePlate() {
        let trimmedNumber = number.trimmingCharacters(in: .whitespaces)
        let trimmedLetters = letters.trimmingCharacters(in: .whitespaces)
        
        // Validation
        if let intNumber = Int(trimmedNumber),
           intNumber > 0 && intNumber < 1000,
           trimmedLetters.count == 3 && trimmedLetters.allSatisfy({ $0.isLetter }) {
            plateNumber = "\(selectedCounty)\(intNumber)\(trimmedLetters)"
        } else {
            plateNumber = ""
        }
    }
    
    private var isPlateValid: Bool {
        if let intNumber = Int(number),
           intNumber > 0 && intNumber < 1000,
           letters.count == 3 && letters.allSatisfy({ $0.isLetter }) {
            return true
        }
        return false
    }
    
}

// MARK: - EU Emblem and Star Shape

extension NumberPlateInputView {
    struct EuropeanEmblemView: View {
        let starCount = 12
        let radius: CGFloat = 9
        let starSize: CGFloat = 5

        var body: some View {
            ZStack {
                ForEach(0..<starCount, id: \.self) { i in
                    let angle = Angle.degrees(Double(i) / Double(starCount) * 360)
                    StarShape()
                        .fill(Color.yellow)
                        .frame(width: starSize, height: starSize)
                        .rotationEffect(.degrees(-18))
                        .offset(x: radius * cos(CGFloat(angle.radians)),
                                y: radius * sin(CGFloat(angle.radians)))
                }
            }
        }
    }

    struct StarShape: Shape {
        func path(in rect: CGRect) -> Path {
            let points = 5
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let angle = .pi * 2 / Double(points)

            var path = Path()
            for i in 0..<points * 2 {
                let isEven = i % 2 == 0
                let r = isEven ? radius : radius * 0.4
                let x = center.x + CGFloat(cos(Double(i) * angle / 2)) * r
                let y = center.y + CGFloat(sin(Double(i) * angle / 2)) * r

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
            return path
        }
    }
}

// MARK: - Preview

struct NumberPlateInputView_Previews: PreviewProvider {
    @State static var plate = "RO TM "
    static var previews: some View {
        NumberPlateInputView(plateNumber: $plate)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

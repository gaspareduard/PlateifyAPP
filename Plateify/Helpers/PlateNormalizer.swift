//
//  PlateNormalizer.swift
//  Plateify
//
//  Created by Eduard Gaspar on 21.05.2025.
//

extension String {
    /// Strip out everything except letters & digits, uppercase the rest.
    var normalizedPlate: String {
        self
          .uppercased()
          .filter { $0.isLetter || $0.isNumber }
    }
}

//
//  RoundedCorner.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//


import SwiftUI
import PassKit

// MARK: - View Extensions

extension View {
    /// Applies corner radius to specific corners

    /// Applies a conditional modifier
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies a shadow with preset values
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - String Extensions

extension String {
    /// Creates a masked version of a string, preserving the first and last n characters
    func masked(preserveFirst: Int = 4, preserveLast: Int = 4, mask: String = "•••") -> String {
        guard self.count > preserveFirst + preserveLast else { return self }
        
        let firstPart = self.prefix(preserveFirst)
        let lastPart = self.suffix(preserveLast)
        
        return "\(firstPart)\(mask)\(lastPart)"
    }
}

// MARK: - Date Extensions

extension Date {
    /// Formats a date for display in a receipt
    func formattedForReceipt() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Returns the date formatted as an ISO string
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: self)
    }
}

// MARK: - Decimal Extensions



// MARK: - PKPayment Extensions

extension PKPayment {
    /// Returns a mock transaction identifier for demos
    var mockTransactionIdentifier: String {
        return "APPL\(Int.random(in: 100000...999999))"
    }
}

// MARK: - Color Extensions

extension Color {
    /// Initializes a color from a hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

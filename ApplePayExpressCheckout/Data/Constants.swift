//
//  Constants.swift
//  ApplePayExpressCheckout
//

import SwiftUI

/// App-wide constants
enum Constants {
    /// App appearance
    enum Theme {
        static let backgroundColor = Color(red: 0.12, green: 0.12, blue: 0.12) // Off-black
        static let accentColor = Color.blue
        static let textColor = Color.white
        static let secondaryTextColor = Color.gray
        static let cardColor = Color(red: 0.18, green: 0.18, blue: 0.18)
    }
    
    /// App metrics
    enum Layout {
        static let spacing: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let cardPadding: CGFloat = 16
    }
    
    /// Tax information
    enum Tax {
        /// Los Angeles, CA Sales Tax Rate (9.5%)
        static let losAngelesSalesTaxRate: Decimal = 0.095
    }
    
    /// Mock data for the catalog
    enum MockData {
        static let products = [
            Product(
                name: "Nike Dunk Olive",
                price: 110.00,
                description: "Iconic color blocking with premium materials and plush padding for game-changing comfort that lasts.",
                imageName: "sneakers_green"
            ),
            Product(
                name: "Nike Dunk Mocha",
                price: 110.00,
                description: "You can always count on a classic. The Dunk Low pairs its iconic color blocking with premium materials",
                imageName: "sneakers_red"
            ),
            Product(
                name: "Nike Air Jordan",
                price: 178.00,
                description: "Originally released to play ball on the court, these iconic kicks level up your street style.",
                imageName: "sneakers_grey"
            ),
            Product(
                name: "Nike Dunk Black",
                price: 94.00,
                description: "Created for the hardwood but taken to the streets, the Nike Dunk Low Retro returns.",
                imageName: "sneakers_black"
            ),
            Product(
                name: "Nike Dunk Blue",
                price: 84.00,
                description: "Created for the hardwood but taken to the streets, the Nike Dunk Low Retro returns.",
                imageName: "sneakers_blue"
            ),
            Product(
                name: "Nike Dunk Off White",
                price: 94.00,
                description: "Created for the hardwood but taken to the streets, the Nike Dunk Low Retro returns.",
                imageName: "sneakers_white"
            )
        ]
        
        static let confirmationPrefix = "SWIFT"
    }
}

/// Extension to format currency values
extension Decimal {
    func asCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }
}

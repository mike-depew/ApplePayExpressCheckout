//
//  ApplePayLaterView.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//

import SwiftUI

/// A reusable view component for displaying Apple Pay Later information
struct ApplePayLaterView: View {
    // MARK: - Properties
    
    /// The type of display for Apple Pay Later
    enum DisplayType {
        case compact    // Minimal display for product listings
        case standard   // Standard display for product details
        case detailed   // Detailed display with more information
    }
    
    let product: Product
    let displayType: DisplayType
    let showLearnMore: Bool
    
    private var isEligible: Bool {
        return ApplePayLaterService.shared.isApplePayLaterAvailable(for: product)
    }
    
    private var installmentAmount: Decimal {
        return ApplePayLaterService.shared.getMonthlyInstallmentAmount(for: product)
    }
    
    // MARK: - Initializers
    init(product: Product, displayType: DisplayType = .standard, showLearnMore: Bool = true) {
        self.product = product
        self.displayType = displayType
        self.showLearnMore = showLearnMore
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if isEligible {
                switch displayType {
                case .compact:
                    compactView
                case .standard:
                    standardView
                case .detailed:
                    detailedView
                }
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Compact view for product listings
    private var compactView: some View {
        HStack(spacing: 4) {
            Image(systemName: "applelogo")
                .font(.caption2)
                .foregroundColor(Constants.Theme.textColor)
            
            Text("Pay Later:")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(Constants.Theme.textColor)
            
            Text("From \(installmentAmount.asCurrencyString())/mo.")
                .font(.caption2)
                .foregroundColor(Constants.Theme.secondaryTextColor)
        }
    }
    
    /// Standard view for product details
    private var standardView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "applelogo")
                    .font(.subheadline)
                    .foregroundColor(Constants.Theme.textColor)
                
                Text("Pay Later")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Theme.textColor)
            }
            
            Text("Pay \(installmentAmount.asCurrencyString())/mo. for 4 months")
                .font(.subheadline)
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            if showLearnMore {
                Button(action: {
                    // In a real app, this would show more information about Apple Pay Later
                }) {
                    Text("Learn more")
                        .font(.caption)
                        .foregroundColor(Constants.Theme.accentColor)
                        .padding(.top, 2)
                }
            }
        }
        .padding(12)
        .background(Constants.Theme.backgroundColor)
        .cornerRadius(Constants.Layout.cornerRadius)
    }
    
    /// Detailed view with more information
    private var detailedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "applelogo")
                    .font(.subheadline)
                    .foregroundColor(Constants.Theme.textColor)
                
                Text("Pay Later")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Theme.textColor)
            }
            
            Text("Pay \(installmentAmount.asCurrencyString())/mo. for 4 months")
                .font(.subheadline)
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            Text("Interest-free installments with Apple Pay Later")
                .font(.caption)
                .foregroundColor(Constants.Theme.secondaryTextColor)
                .padding(.top, 2)
            
            Text("Available for purchases between $50 and $1,000")
                .font(.caption)
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            if showLearnMore {
                Button(action: {
                    // In a real app, this would show more information about Apple Pay Later
                }) {
                    Text("Learn more about Apple Pay Later")
                        .font(.caption)
                        .foregroundColor(Constants.Theme.accentColor)
                        .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(Constants.Theme.backgroundColor)
        .cornerRadius(Constants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(Constants.Theme.cardColor, lineWidth: 1)
        )
    }
}

/// A view modifier to easily add Apple Pay Later to any view
struct ApplePayLaterModifier: ViewModifier {
    let product: Product
    let displayType: ApplePayLaterView.DisplayType
    let showLearnMore: Bool
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content
            
            ApplePayLaterView(
                product: product,
                displayType: displayType,
                showLearnMore: showLearnMore
            )
        }
    }
}

/// Extension to add Apple Pay Later to any view
extension View {
    /// Adds Apple Pay Later information to a view
    /// - Parameters:
    ///   - product: The product to check for Apple Pay Later eligibility
    ///   - displayType: The display style for Apple Pay Later information
    ///   - showLearnMore: Whether to show the "Learn more" button
    /// - Returns: The modified view with Apple Pay Later information
    func withApplePayLater(
        for product: Product,
        displayType: ApplePayLaterView.DisplayType = .standard,
        showLearnMore: Bool = true
    ) -> some View {
        self.modifier(ApplePayLaterModifier(
            product: product,
            displayType: displayType,
            showLearnMore: showLearnMore
        ))
    }
}

// MARK: - Preview
struct ApplePayLaterView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Constants.Theme.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Eligible product
                ApplePayLaterView(
                    product: Product(
                        name: "Premium Sneakers",
                        price: 99.99,
                        description: "High-quality premium sneakers",
                        imageName: "sneakers_black"
                    ),
                    displayType: .compact
                )
                .padding()
                .background(Constants.Theme.cardColor)
                .cornerRadius(Constants.Layout.cornerRadius)
                
                // Standard view
                ApplePayLaterView(
                    product: Product(
                        name: "Premium Sneakers",
                        price: 99.99,
                        description: "High-quality premium sneakers",
                        imageName: "sneakers_black"
                    )
                )
                
                // Detailed view
                ApplePayLaterView(
                    product: Product(
                        name: "Premium Sneakers",
                        price: 99.99,
                        description: "High-quality premium sneakers",
                        imageName: "sneakers_black"
                    ),
                    displayType: .detailed
                )
                
                // Non-eligible product (should show nothing)
                ApplePayLaterView(
                    product: Product(
                        name: "Budget Socks",
                        price: 9.99,
                        description: "Budget-friendly socks",
                        imageName: "sneakers_blue"
                    )
                )
                .padding()
                .background(Constants.Theme.cardColor)
                .cornerRadius(Constants.Layout.cornerRadius)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}

//
//  ProductCard.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.

import SwiftUI

// Card view for displaying product information
struct ProductCard: View {
    // MARK: - Properties
    let product: Product
    let quantity: Int
    let onAddToCart: () -> Void
    let onUpdateQuantity: (Int) -> Void
    
    @State private var isShowingDetails = false
    
    // Apple Pay Later display properties
    private var isApplePayLaterEligible: Bool {
        return ApplePayLaterService.shared.isApplePayLaterAvailable(for: product.price)
    }
    
    private var installmentAmount: Decimal {
        return ApplePayLaterService.shared.getMonthlyInstallmentAmount(for: product.price)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Remove spacing between elements
            // Product Image
            ZStack(alignment: .topTrailing) {
                // Load the image from the asset catalog
                Image(product.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity) // Make image fill card width
                    .background(Color.gray.opacity(0.2))
                
                // Show quantity badge if item is in cart
                if quantity > 0 {
                    Text("\(quantity)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Constants.Theme.accentColor)
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Product Name
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(Constants.Theme.textColor)
                    .lineLimit(1)
                
                // Product Price
                Text(product.price.asCurrencyString())
                    .font(.subheadline)
                    .foregroundColor(Constants.Theme.accentColor)
                
                // Apple Pay Later information if eligible
                if isApplePayLaterEligible {
                    HStack(spacing: 4) {
                        // Apple Pay Logo
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
                    .padding(.vertical, 4)
                }
                
                // Add to Cart Button or Quantity Selector
                if quantity == 0 {
                    Button(action: onAddToCart) {
                        Text("Add to Cart")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Constants.Theme.accentColor)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                } else {
                    QuantitySelector(
                        quantity: quantity,
                        onIncrement: {
                            onUpdateQuantity(quantity + 1)
                        },
                        onDecrement: {
                            if quantity > 1 {
                                onUpdateQuantity(quantity - 1)
                            } else {
                                onUpdateQuantity(0)
                            }
                        }
                    )
                    .padding(.top, 4)
                }
            }
            .padding(10)
        }
        .background(Constants.Theme.cardColor)
        .cornerRadius(Constants.Layout.cornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        // Tap to show details
        .onTapGesture {
            isShowingDetails.toggle()
        }
        .frame(maxWidth: .infinity) // Fill available width
        .sheet(isPresented: $isShowingDetails) {
            ProductDetailView(product: product, quantity: quantity, onAddToCart: onAddToCart, onUpdateQuantity: onUpdateQuantity)
        }
    }
}

// MARK: - Preview
struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProductCard(
                product: Product(
                    id: UUID(),
                    name: "Swift T-Shirt",
                    price: 29.99,
                    description: "Comfortable cotton t-shirt with Swift logo",
                    imageName: "swiftStore_shirt" // Don't include .jpg here
                ),
                quantity: 0,
                onAddToCart: {},
                onUpdateQuantity: { _ in }
            )
            
            ProductCard(
                product: Product(
                    id: UUID(),
                    name: "Swift Hoodie",
                    price: 59.99,
                    description: "Warm hoodie with Swift logo for cold coding sessions",
                    imageName: "swiftStore_hoodie" // Don't include .jpg here
                ),
                quantity: 2,
                onAddToCart: {},
                onUpdateQuantity: { _ in }
            )
            
            // Add a preview with a product eligible for Apple Pay Later
            ProductCard(
                product: Product(
                    id: UUID(),
                    name: "Premium Swift Package",
                    price: 99.99,
                    description: "Complete Swift development package with accessories",
                    imageName: "swiftStore_hoodie"
                ),
                quantity: 0,
                onAddToCart: {},
                onUpdateQuantity: { _ in }
            )
        }
        .padding()
        .background(Constants.Theme.backgroundColor)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}

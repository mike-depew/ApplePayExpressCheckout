//
//  CatalogView.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/26/25.
//
import SwiftUI

/// View for displaying the product catalog
struct CatalogView: View {
    // MARK: - Properties
    @EnvironmentObject private var cartManager: CartManager
    
    // Define exactly 2 columns with fixed size
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private let products = Constants.MockData.products
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Layout.spacing) {
                
                Text("Mens")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .foregroundColor(Constants.Theme.textColor)
                
                Text("Tap on an item to add it to your cart")
                    .font(.subheadline)
                    .foregroundColor(Constants.Theme.secondaryTextColor)
                    .padding(.horizontal)
                
                // Product Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(products) { product in
                        ProductCard(
                            product: product,
                            quantity: cartManager.quantity(for: product),
                            onAddToCart: {
                                cartManager.add(product: product)
                                // Provide haptic feedback when adding to cart
                                let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
                                impactGenerator.impactOccurred()
                            },
                            onUpdateQuantity: { quantity in
                                if let index = cartManager.items.firstIndex(where: { $0.product.id == product.id }) {
                                    let item = cartManager.items[index]
                                    cartManager.updateQuantity(for: item, to: quantity)
                                }
                            }
                        )
                        .padding(.horizontal, 8)
                        .padding(.bottom, 16)
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
        }
        .background(Constants.Theme.backgroundColor)
    }
}

// MARK: - Preview
struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CatalogView()
                .environmentObject(CartManager())
        }
        .preferredColorScheme(.dark)
    }
}

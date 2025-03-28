//
//  ProductCard.swift
//  ApplePayExpressCheckout
//

import SwiftUI

/// Card view for displaying product information
struct ProductCard: View {
    // MARK: - Properties
    let product: Product
    let quantity: Int
    let onAddToCart: () -> Void
    let onUpdateQuantity: (Int) -> Void
    
    @State private var isShowingDetails = false
    
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

/// Detail view for a product
struct ProductDetailView: View {
    // MARK: - Properties
    let product: Product
    let quantity: Int
    let onAddToCart: () -> Void
    let onUpdateQuantity: (Int) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Product Image
                    HStack {
                        Spacer()
                        // Load the image from the asset catalog
                        Image(product.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 280)
                            .background(Color.gray.opacity(0.2)) // Add background to see the frame
                        Spacer()
                    }
                    .padding()
                    
                    // Product Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(product.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Theme.textColor)
                        
                        Text(product.price.asCurrencyString())
                            .font(.title2)
                            .foregroundColor(Constants.Theme.accentColor)
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(Constants.Theme.secondaryTextColor)
                            .padding(.top, 4)
                        
                        // Add to Cart or Quantity Selector
                        HStack {
                            if quantity == 0 {
                                Button(action: {
                                    onAddToCart()
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Add to Cart")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Constants.Theme.accentColor)
                                        .cornerRadius(Constants.Layout.cornerRadius)
                                }
                            } else {
                                VStack(spacing: 12) {
                                    Text("In Cart: \(quantity)")
                                        .font(.headline)
                                        .foregroundColor(Constants.Theme.secondaryTextColor)
                                    
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
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                }
            }
            .background(Constants.Theme.backgroundColor)
            .navigationBarTitle("Product Details", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Constants.Theme.secondaryTextColor)
                    .font(.title3)
            })
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
        }
        .padding()
        .background(Constants.Theme.backgroundColor)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}

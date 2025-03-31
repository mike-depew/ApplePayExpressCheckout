//
//  ProductDetailView.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//

import SwiftUI
import PassKit

/// View for displaying product details
struct ProductDetailView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var cartManager: CartManager
    
    let product: Product
    var quantity: Int
    let onAddToCart: () -> Void
    let onUpdateQuantity: (Int) -> Void
    
    @State private var selectedQuantity: Int
    
    // Apple Pay Later properties
    private var isApplePayLaterEligible: Bool {
        return ApplePayLaterService.shared.isApplePayLaterAvailable(for: product)
    }
    
    private var installmentAmount: Decimal {
        return ApplePayLaterService.shared.getMonthlyInstallmentAmount(for: product)
    }
    
    // MARK: - Initializer
    init(product: Product, quantity: Int, onAddToCart: @escaping () -> Void, onUpdateQuantity: @escaping (Int) -> Void) {
        self.product = product
        self.quantity = quantity
        self.onAddToCart = onAddToCart
        self.onUpdateQuantity = onUpdateQuantity
        _selectedQuantity = State(initialValue: max(1, quantity))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background color
            Constants.Theme.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Product Image
                    Image(product.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(Constants.Theme.cardColor)
                        .cornerRadius(Constants.Layout.cornerRadius)
                    
                    // Product Info
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and price
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Theme.textColor)
                                
                                Text(product.price.asCurrencyString())
                                    .font(.title3)
                                    .foregroundColor(Constants.Theme.accentColor)
                            }
                            
                            Spacer()
                        }
                        
                        // Description
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(Constants.Theme.secondaryTextColor)
                            .padding(.vertical, 4)
                        
                        // Apple Pay Later Information (if eligible)
                        if isApplePayLaterEligible {
                            applePayLaterSection
                        }
                        
                        // Quantity selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quantity")
                                .font(.headline)
                                .foregroundColor(Constants.Theme.textColor)
                            
                            QuantitySelector(
                                quantity: selectedQuantity,
                                onIncrement: { selectedQuantity += 1 },
                                onDecrement: { if selectedQuantity > 1 { selectedQuantity -= 1 } }
                            )
                        }
                        .padding(.vertical, 4)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Add to Cart or Update Quantity
                            if quantity > 0 {
                                // Item already in cart
                                Button(action: {
                                    onUpdateQuantity(selectedQuantity)
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Update Quantity")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Constants.Theme.accentColor)
                                        .cornerRadius(Constants.Layout.cornerRadius)
                                }
                            } else {
                                // Item not in cart
                                Button(action: {
                                    onAddToCart()
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Add to Cart")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Constants.Theme.accentColor)
                                        .cornerRadius(Constants.Layout.cornerRadius)
                                }
                            }
                            
                            // Express Checkout with Apple Pay (if available)
                            if PKPaymentAuthorizationController.canMakePayments() {
                                Button(action: {
                                    // Express checkout would be implemented here
                                    // For demo purposes, just add to cart
                                    onAddToCart()
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "applelogo")
                                            .font(.system(size: 18))
                                        
                                        Text("Express Checkout")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(Constants.Theme.textColor)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(Constants.Layout.cornerRadius)
                                }
                                
                                // Show Apple Pay Later for Express Checkout if eligible
                                if isApplePayLaterEligible {
                                    expressCheckoutApplePayLaterInfo
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Constants.Theme.cardColor)
                    .cornerRadius(Constants.Layout.cornerRadius)
                }
                .padding()
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Constants.Theme.secondaryTextColor.opacity(0.8))
                            .padding()
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    /// Apple Pay Later information section
    private var applePayLaterSection: some View {
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
            
            Text("Interest-free payments with Apple Pay Later")
                .font(.caption)
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            Button(action: {
                // In a real app, this would link to more information about Apple Pay Later
            }) {
                Text("Learn more")
                    .font(.caption)
                    .foregroundColor(Constants.Theme.accentColor)
                    .padding(.top, 2)
            }
        }
        .padding(12)
        .background(Constants.Theme.backgroundColor)
        .cornerRadius(Constants.Layout.cornerRadius)
    }
    
    /// Apple Pay Later for Express Checkout
    private var expressCheckoutApplePayLaterInfo: some View {
        HStack(spacing: 4) {
            Text("Or pay")
                .font(.caption)
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            Text("\(installmentAmount.asCurrencyString())/mo.")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            Text("for 4 months with")
                .font(.caption)
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            Image(systemName: "applelogo")
                .font(.caption)
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            Text("Pay Later")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Constants.Theme.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.top, 4)
    }
}

// MARK: - Preview
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(
            product: Constants.MockData.products[0],
            quantity: 0,
            onAddToCart: {},
            onUpdateQuantity: { _ in }
        )
        .environmentObject(CartManager())
        .preferredColorScheme(.dark)
    }
}

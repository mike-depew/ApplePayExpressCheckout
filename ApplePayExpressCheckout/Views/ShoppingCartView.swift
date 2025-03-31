//
//  ShoppingCartView.swift
//  ApplePayExpressCheckout

//  Created by Mike Depew.

import SwiftUI
import PassKit

// View for displaying the shopping cart and checkout
struct ShoppingCartView: View {
    // MARK: - Properties
    @EnvironmentObject private var cartManager: CartManager
    @ObservedObject var viewModel: CartViewModel
    @Binding var showReceipt: Bool
    @Binding var receiptInfo: ReceiptInfo?
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Constants.Theme.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            // Empty Cart State
            if viewModel.cartItems.isEmpty {
                emptyCartView
            } else {
                // Cart Items
                VStack {
                    cartItemsList
                    
                    Spacer()
                    
                    // Summary and Checkout
                    VStack(spacing: 0) {
                        OrderSummary(
                            subtotal: viewModel.subtotal,
                            tax: viewModel.tax,
                            total: viewModel.total
                        )
                        
                        // Apple Pay Button with Apple Pay Later info
                        ApplePayButton(
                            isEnabled: viewModel.isApplePayAvailable && !viewModel.isProcessingPayment,
                            isLoading: viewModel.isProcessingPayment,
                            action: viewModel.checkout,
                            showApplePayLater: true,
                            amount: NSDecimalNumber(decimal: viewModel.total).doubleValue                        )
                        .padding()
                    }
                    .background(Constants.Theme.cardColor)
                    .clipShape(RoundedCorners(radius: Constants.Layout.cornerRadius, corners: [.topLeft, .topRight]))
                }
            }
        }
        // Present receipt view when showReceipt is true
        .sheet(isPresented: $viewModel.showReceipt) {
            if let receiptInfo = viewModel.receiptInfo {
                ReceiptView(
                    viewModel: ReceiptViewModel(receiptInfo: receiptInfo),
                    isPresented: $viewModel.showReceipt
                )
            }
        }
        // Update the view model with the cart manager on appear
        .onAppear {
            viewModel.updateWithCartManager(cartManager)
            setupBindings()
        }
        
        // Clean up bindings when the view disappears
        .onDisappear {
            cleanupBindings()
        }
    }
    
    // Set up bindings to monitor changes to viewModel.receiptInfo
    private func setupBindings() {
        // Cancel any existing subscription first to avoid duplicates
        cleanupBindings()
        
        // Bind to detect completion of checkout and sync with parent's receipt state
        viewModel.$receiptInfo
            .compactMap { $0 }  // Filter out nil values
            .sink { newReceiptInfo in
                self.receiptInfo = newReceiptInfo
                self.showReceipt = true
            }
            .store(in: &viewModel.cancellables)
            
        // Sync parent's showReceipt with viewModel's showReceipt
        viewModel.$showReceipt
            .sink { isShowing in
                self.showReceipt = isShowing
            }
            .store(in: &viewModel.cancellables)
            
        // Also sync from parent to viewModel
        // This observer is necessary to handle the case where the receipt is dismissed from the parent view
        self.showReceipt = viewModel.showReceipt
    }
    
    // Clean up bindings when leaving the view
    private func cleanupBindings() {
        viewModel.cancellables.removeAll()
    }
    
    // MARK: - Subviews
    
    // Empty cart placeholder view
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 70))
                .foregroundColor(Constants.Theme.secondaryTextColor)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Theme.textColor)
            
            Text("Add items from the catalog to get started")
                .font(.body)
                .foregroundColor(Constants.Theme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // Switch to catalog tab
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController,
                   let tabBarController = rootViewController.children.first as? UITabBarController {
                    tabBarController.selectedIndex = 0
                }
            }) {
                Text("Browse Catalog")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Constants.Theme.accentColor)
                    .cornerRadius(Constants.Layout.cornerRadius)
            }
            .padding(.top, 10)
        }
        .padding()
    }
    
    // List of items in the cart
    private var cartItemsList: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Layout.spacing) {
                // Fixed: Access cartItems as an instance property
                ForEach(viewModel.cartItems) { item in
                    VStack(spacing: 4) {
                        CartItemRow(
                            item: item,
                            onUpdateQuantity: { quantity in
                                viewModel.updateQuantity(for: item, to: quantity)
                            },
                            onRemove: {
                                viewModel.removeItem(item)
                            }
                        )
                        .padding(.horizontal)
                        
                        // Apple Pay Later for individual items if eligible
                        if ApplePayLaterService.shared.isApplePayLaterAvailable(for: item.subtotal) {
                            HStack(spacing: 4) {
                                Image(systemName: "applelogo")
                                    .font(.caption2)
                                
                                Text("Pay Later:")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                
                                let installmentAmount = ApplePayLaterService.shared.getMonthlyInstallmentAmount(for: item.subtotal)
                                Text("\(installmentAmount.asCurrencyString())/mo. for 4 months")
                                    .font(.caption2)
                            }
                            .foregroundColor(Constants.Theme.secondaryTextColor)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

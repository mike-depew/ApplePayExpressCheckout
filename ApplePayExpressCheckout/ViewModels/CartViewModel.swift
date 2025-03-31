//  CartViewModel.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.

import Foundation
import Combine
import PassKit

/// View model for the shopping cart
class CartViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cartItems: [CartItem] = []
    @Published var subtotal: Decimal = 0
    @Published var tax: Decimal = 0
    @Published var total: Decimal = 0
    
    @Published var isApplePayAvailable: Bool = false
    @Published var isApplePayLaterAvailable: Bool = false
    @Published var isProcessingPayment: Bool = false
    
    @Published var showReceipt: Bool = false
    @Published var receiptInfo: ReceiptInfo?
    
    // MARK: - Properties
    private var cartManager: CartManager?
    private var applePayHandler = ApplePayHandler()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init() {
        applePayHandler.delegate = self
        checkApplePayAvailability()
    }
    
    // MARK: - Public Methods
    
    /// Updates the view model with the current cart state
    /// - Parameter cartManager: The cart manager to sync with
    func updateWithCartManager(_ cartManager: CartManager) {
        self.cartManager = cartManager
        
        // Set up a subscription to cartManager updates
        cartManager.$items
            .sink { [weak self] items in
                guard let self = self else { return }
                self.cartItems = items
                self.updateTotals()
            }
            .store(in: &cancellables)
        
        // Initial update
        cartItems = cartManager.items
        updateTotals()
    }
    
    func updateQuantity(for item: CartItem, to quantity: Int) {
        cartManager?.updateQuantity(for: item, to: quantity)
    }

    func removeItem(_ item: CartItem) {
        cartManager?.remove(cartItem: item)
    }
    
    /// Starts the checkout process
    func checkout() {
        guard !isProcessingPayment else { return }
        
        isProcessingPayment = true
        
        // Use the Apple Pay handler to process payment
        applePayHandler.startPayment(subtotal: subtotal, tax: tax) { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                
                if success {
                    self.handleSuccessfulPayment()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Checks if Apple Pay is available on this device
    private func checkApplePayAvailability() {
        isApplePayAvailable = ApplePayUtility.canMakePaymentsWithNetworks()
    }
    
    /// Updates the totals based on current cart items
    private func updateTotals() {
        // Calculate subtotal
        subtotal = cartItems.reduce(0) { $0 + $1.subtotal }
        
        // Calculate tax
        tax = (subtotal * Constants.Tax.losAngelesSalesTaxRate).rounded(2)
        
        // Calculate total
        total = subtotal + tax
        
        // Check Apple Pay Later availability
        isApplePayLaterAvailable = ApplePayLaterService.shared.isApplePayLaterAvailable(for: total)
    }
    
    /// Handles a successful payment
    private func handleSuccessfulPayment() {
        guard let items = cartManager?.items else { return }
        
        // Create a shipping info based on the payment
        let shippingInfo = ShippingInfo.mockShippingInfo
        
        // Generate a unique confirmation number
        let confirmationNumber = "\(Constants.MockData.confirmationPrefix)-\(Int.random(in: 100000...999999))"
        
        // Create receipt info
        let receiptInfo = ReceiptInfo(
            items: items,
            subtotal: subtotal,
            tax: tax,
            total: total,
            shippingInfo: shippingInfo,
            confirmationNumber: confirmationNumber,
            purchaseDate: Date()
        )
        
        // Update receipt info
        self.receiptInfo = receiptInfo
        self.showReceipt = true
        
        // Clear the cart after successful purchase
        cartManager?.clearCart()
    }
}

// MARK: - ApplePayHandlerDelegate
extension CartViewModel: ApplePayHandlerDelegate {
    func didFinishPayment(success: Bool) {
        DispatchQueue.main.async {
            self.isProcessingPayment = false
        }
    }
}


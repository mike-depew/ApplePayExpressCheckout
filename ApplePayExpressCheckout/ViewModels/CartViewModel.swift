//
//  CartViewModel.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/26/25.
//
import Foundation
import Combine
import SwiftUI
import PassKit  // Explicit import for PassKit

/// ViewModel to handle cart-related logic
class CartViewModel: ObservableObject {
    // MARK: - Dependencies
    private var cartManager: CartManaging?
    private let taxCalculator: TaxCalculating
    private let applePayHandler: ApplePayHandling
    
    // MARK: - Publishers
    @Published var cartItems: [CartItem] = []
    @Published var subtotal: Decimal = 0
    @Published var tax: Decimal = 0
    @Published var total: Decimal = 0
    @Published var isProcessingPayment: Bool = false
    @Published var showReceipt: Bool = false
    @Published var receiptInfo: ReceiptInfo?
    
    // MARK: - Private properties
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(
        cartManager: CartManaging? = nil,
        taxCalculator: TaxCalculating = TaxCalculator(),
        applePayHandler: ApplePayHandling = ApplePayHandler()
    ) {
        self.cartManager = cartManager
        self.taxCalculator = taxCalculator
        self.applePayHandler = applePayHandler
        
        if let cartManager = cartManager {
            setupBindings(with: cartManager)
        }
    }
    
    // MARK: - Public methods
    
    /// Updates the view model with a cart manager instance
    /// - Parameter cartManager: The cart manager to use
    func updateWithCartManager(_ cartManager: CartManaging) {
        self.cartManager = cartManager
        setupBindings(with: cartManager)
    }
    
    /// Updates the quantity of an item in the cart
    /// - Parameters:
    ///   - cartItem: The cart item to update
    ///   - quantity: The new quantity
    func updateQuantity(for cartItem: CartItem, to quantity: Int) {
        cartManager?.updateQuantity(for: cartItem, to: quantity)
    }
    
    /// Removes an item from the cart
    /// - Parameter cartItem: The cart item to remove
    func removeItem(_ cartItem: CartItem) {
        cartManager?.remove(cartItem: cartItem)
    }
    
    /// Initiates the Apple Pay checkout process
    func checkout() {
        guard !cartItems.isEmpty, let cartManager = cartManager else { return }
        
        isProcessingPayment = true
        
        applePayHandler.startPayment(subtotal: subtotal, tax: tax) { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                
                if success {
                    // Generate confirmation number
                    let confirmationNumber = self.generateConfirmationNumber()
                    
                    // Create receipt info
                    self.receiptInfo = ReceiptInfo(
                        items: self.cartItems,
                        subtotal: self.subtotal,
                        tax: self.tax,
                        total: self.total,
                        shippingInfo: ShippingInfo.mockShippingInfo,
                        confirmationNumber: confirmationNumber,
                        purchaseDate: Date()
                    )
                    
                    // Show receipt view
                    self.showReceipt = true
                    
                    // Clear the cart
                    cartManager.clearCart()
                }
            }
        }
    }
    
    /// Checks if Apple Pay is available on the device
     var isApplePayAvailable: Bool {
         return PKPaymentAuthorizationController.canMakePayments()  // Use PassKit method directly
     }
    
    // MARK: - Private methods
    
    /// Sets up data bindings for reactive updates
    private func setupBindings(with cartManager: CartManaging) {
        // Cancel any existing subscriptions
        cancellables.removeAll()
        
        // Set up new subscriptions
        cartManager.itemsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.cartItems = items
                self.updateCalculations()
            }
            .store(in: &cancellables)
        
        // Immediately update with current data
        self.cartItems = cartManager.items
        self.updateCalculations()
    }
    
    /// Updates all cart calculations (subtotal, tax, total)
    private func updateCalculations() {
        guard let cartManager = cartManager else { return }
        
        self.subtotal = cartManager.subtotal
        self.tax = taxCalculator.calculateTax(forSubtotal: subtotal)
        self.total = taxCalculator.calculateTotal(forSubtotal: subtotal)
    }
    
    /// Generates a random confirmation number for orders
    private func generateConfirmationNumber() -> String {
        let randomPart = String(format: "%06d", Int.random(in: 100000...999999))
        return "\(Constants.MockData.confirmationPrefix)-\(randomPart)"
    }
}

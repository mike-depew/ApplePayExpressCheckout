//
//  ApplePayLaterService.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//

import PassKit
import SwiftUI

// Service responsible for Apple Pay Later functionality
class ApplePayLaterService {
    // MARK: - Singleton
    static let shared = ApplePayLaterService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    // Checks if Apple Pay Later is available for the specified product
    // - Parameter product: The product to check for Apple Pay Later eligibility
    // - Returns: Boolean indicating if Apple Pay Later is available
    func isApplePayLaterAvailable(for product: Product) -> Bool {
        return isApplePayLaterAvailable(for: product.price)
    }
    
    // Checks if Apple Pay Later is available for the specified amount
    // - Parameter amount: The purchase amount to check for Apple Pay Later eligibility
    // - Returns: Boolean indicating if Apple Pay Later is available
    func isApplePayLaterAvailable(for amount: Decimal) -> Bool {
        // Apple Pay Later is typically available in the US for purchases between $50 and $1000
        // This is a mock check since we're creating a demo
        let minAmount: Decimal = 50.0
        let maxAmount: Decimal = 1000.0
        
        return PKPaymentAuthorizationController.canMakePayments() &&
               amount >= minAmount &&
               amount <= maxAmount
    }
    
    // Checks if Apple Pay Later is available for the specified cart item
    // - Parameter item: The cart item to check for Apple Pay Later eligibility
    // - Returns: Boolean indicating if Apple Pay Later is available
    func isApplePayLaterAvailable(for item: CartItem) -> Bool {
        return isApplePayLaterAvailable(for: item.subtotal)
    }
    
    // Gets monthly installment amount for Apple Pay Later
    // - Parameter product: The product to calculate installments for
    // - Returns: The estimated monthly payment amount
    func getMonthlyInstallmentAmount(for product: Product) -> Decimal {
        return getMonthlyInstallmentAmount(for: product.price)
    }
    
    // Gets monthly installment amount for Apple Pay Later
    // - Parameter cartItem: The cart item to calculate installments for
    // - Returns: The estimated monthly payment amount
    func getMonthlyInstallmentAmount(for cartItem: CartItem) -> Decimal {
        return getMonthlyInstallmentAmount(for: cartItem.subtotal)
    }
    
    // Gets monthly installment amount for Apple Pay Later
    // - Parameter totalAmount: Total purchase amount
    // - Returns: The estimated monthly payment amount
    func getMonthlyInstallmentAmount(for totalAmount: Decimal) -> Decimal {
        // Apple Pay Later typically splits payments into 4 equal installments
        // This is a simplified calculation for demo purposes
        return (totalAmount / 4).rounded(2)
    }
    
    // Gets formatted installment message for the given product
    // - Parameter product: The product to check
    // - Returns: Formatted message for displaying Apple Pay Later information
    func getInstallmentMessage(for product: Product) -> String? {
        return getInstallmentMessage(for: product.price)
    }
    
    // Gets formatted installment message for the given cart item
    // - Parameter item: The cart item to check
    // - Returns: Formatted message for displaying Apple Pay Later information
    func getInstallmentMessage(for item: CartItem) -> String? {
        return getInstallmentMessage(for: item.subtotal)
    }
    
    /// Gets formatted installment message for the given amount
    /// - Parameter amount: The total purchase amount
    /// - Returns: Formatted message for displaying Apple Pay Later information
    func getInstallmentMessage(for amount: Decimal) -> String? {
        guard isApplePayLaterAvailable(for: amount) else {
            return nil
        }
        
        let installmentAmount = getMonthlyInstallmentAmount(for: amount)
        return "Pay \(installmentAmount.asCurrencyString())/mo. for 4 months with Apple Pay Later"
    }
    
    /// Gets the Apple Pay Later mark image for use in UI
    /// - Returns: UIImage of the Apple Pay Later mark
    func getApplePayLaterMark() -> UIImage? {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        
        let size = button.bounds.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { _ in
            button.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        }
    }
    
    // Updates a payment request to include Apple Pay Later if available
    // - Parameters:
    //   - request: The existing payment request
    //   - amount: The total purchase amount
    // - Returns: Updated payment request with Apple Pay Later if available
    func configurePaymentRequestForLater(_ request: PKPaymentRequest, amount: Decimal) -> PKPaymentRequest {
        // For real implementation, nothing needs to be modified as Apple handles the display
        // of Apple Pay Later options automatically when available
        
        // For our demo, we'll just ensure the appropriate fields are set
        if isApplePayLaterAvailable(for: amount) {
            // Ensure billing and shipping contact fields are required
            // as these are typically needed for Apple Pay Later
            request.requiredBillingContactFields = [.postalAddress, .name, .phoneNumber, .emailAddress]
            request.requiredShippingContactFields = [.postalAddress, .name, .phoneNumber, .emailAddress]
        }
        
        return request
    }
}

// MARK: - Helper Extensions

extension Decimal {
    // Rounds the decimal to the specified number of places
    // - Parameter places: Number of decimal places to round to
    // - Returns: Rounded decimal value
    func rounded(_ places: Int) -> Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, places, .plain) // Uses plain rounding mode
        return result
    }
}

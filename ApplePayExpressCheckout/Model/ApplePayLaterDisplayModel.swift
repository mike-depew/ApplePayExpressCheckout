//
//  ApplePayLaterDisplayModel.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//

import Foundation
import SwiftUI

/// Model for Apple Pay Later display requirements
struct ApplePayLaterDisplayModel {
    // MARK: - Properties
    
    /// The purchase amount to check eligibility against
    let amount: Decimal
    
    /// Whether Apple Pay Later is eligible for this amount
    var isEligible: Bool {
        return ApplePayLaterService.shared.isApplePayLaterAvailable(for: amount)
    }
    
    /// The monthly installment amount
    var monthlyAmount: Decimal {
        return ApplePayLaterService.shared.getMonthlyInstallmentAmount(for: amount)
    }
    
    /// The formatted monthly amount as a string
    var monthlyAmountFormatted: String {
        return monthlyAmount.asCurrencyString()
    }
    
    /// Short message for Apple Pay Later
    var shortMessage: String {
        return "Pay \(monthlyAmountFormatted)/mo."
    }
    
    /// Full message for Apple Pay Later
    var fullMessage: String? {
        guard isEligible else { return nil }
        return "Pay \(monthlyAmountFormatted)/mo. for 4 months with Apple Pay Later"
    }
    
    /// The number of installments
    let installments: Int = 4
    
    // MARK: - Initializer
    init(amount: Decimal) {
        self.amount = amount
    }
}

/// Extension to create standard display strings
extension ApplePayLaterDisplayModel {
    /// Returns a formatted message for product listings
    var productListingMessage: String? {
        guard isEligible else { return nil }
        return "From \(monthlyAmountFormatted)/mo. for 4 months"
    }
    
    /// Returns a formatted message for product detail
    var productDetailMessage: String? {
        guard isEligible else { return nil }
        return fullMessage
    }
    
    /// Returns a formatted message for cart
    var cartMessage: String? {
        guard isEligible else { return nil }
        return "Pay in 4 installments of \(monthlyAmountFormatted)"
    }
}

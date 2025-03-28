//
//  ApplePayUtility.swift
//  ApplePayExpressCheckout
//
import PassKit
import Foundation

/// Utility class for Apple Pay operations
class ApplePayUtility {
    /// Checks if Apple Pay is available on the device
    static func canMakePayments() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments()
    }
    
    /// Checks if Apple Pay is available with specific networks
    static func canMakePaymentsWithNetworks() -> Bool {
        let networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
        return PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
    }
    
    /// Creates a standard payment request for the app
    static func createPaymentRequest(subtotal: Decimal, tax: Decimal) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        
        // Set the merchant identifier from your Apple Developer account
        request.merchantIdentifier = "merchant.com.yourcompany.applepayexpresscheckout"
        
        // Set the supported networks for the payment
        request.supportedNetworks = [.visa, .masterCard, .amex]
        
        // Set the capabilities required for the payment
        request.merchantCapabilities = .threeDSecure
        
        // Set the country and currency
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        // Configure the payment summary items
        let subtotalItem = PKPaymentSummaryItem(
            label: "Subtotal",
            amount: NSDecimalNumber(decimal: subtotal)
        )
        
        let taxItem = PKPaymentSummaryItem(
            label: "Tax",
            amount: NSDecimalNumber(decimal: tax)
        )
        
        let totalItem = PKPaymentSummaryItem(
            label: "Express Checkout",
            amount: NSDecimalNumber(decimal: subtotal + tax)
        )
        
        request.paymentSummaryItems = [subtotalItem, taxItem, totalItem]
        
        return request
    }
}

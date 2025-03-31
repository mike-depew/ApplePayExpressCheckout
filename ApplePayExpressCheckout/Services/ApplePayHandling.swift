//  ApplePayHandler.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.

import Foundation
import PassKit

/// Protocol defining Apple Pay operations
protocol ApplePayHandling {
    var paymentAuthorizationController: PKPaymentAuthorizationController? { get }
    func createPaymentRequest(subtotal: Decimal, tax: Decimal) -> PKPaymentRequest
    func startPayment(subtotal: Decimal, tax: Decimal, completion: @escaping (Bool) -> Void)
}

/// Delegate protocol to handle Apple Pay payment results
protocol ApplePayHandlerDelegate: AnyObject {
    func didFinishPayment(success: Bool)
}

/// Handles Apple Pay payments
class ApplePayHandler: NSObject, ApplePayHandling {
    
    // MARK: - Properties
    weak var delegate: ApplePayHandlerDelegate?
    var paymentAuthorizationController: PKPaymentAuthorizationController?
    var paymentCompletion: ((Bool) -> Void)?
    
    // MARK: - Initializer
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Creates a payment request with the appropriate payment details
    /// - Parameters:
    ///   - subtotal: The pre-tax amount
    ///   - tax: The tax amount
    /// - Returns: A configured PKPaymentRequest
    func createPaymentRequest(subtotal: Decimal, tax: Decimal) -> PKPaymentRequest {
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
        
        // Configure for Apple Pay Later if available
        configureForApplePayLater(request, amount: subtotal + tax)
        
        return request
    }
    
    /// Starts the Apple Pay payment process
    /// - Parameters:
    ///   - subtotal: The subtotal amount
    ///   - tax: The tax amount
    ///   - completion: Completion handler called when payment finishes
    func startPayment(subtotal: Decimal, tax: Decimal, completion: @escaping (Bool) -> Void) {
        let paymentRequest = createPaymentRequest(subtotal: subtotal, tax: tax)
        paymentCompletion = completion
        
        paymentAuthorizationController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentAuthorizationController?.delegate = self
        
        paymentAuthorizationController?.present { presented in
            if !presented {
                self.paymentCompletion?(false)
                self.delegate?.didFinishPayment(success: false)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Configures the payment request for Apple Pay Later
    /// - Parameters:
    ///   - request: The payment request to configure
    ///   - amount: The total purchase amount
    private func configureForApplePayLater(_ request: PKPaymentRequest, amount: Decimal) {
        // Check if the amount is eligible for Apple Pay Later
        if ApplePayLaterService.shared.isApplePayLaterAvailable(for: amount) {
            // Configure billing and contact fields for Apple Pay Later
            // Apple Pay Later typically requires these fields
            request.requiredBillingContactFields = [.postalAddress, .name, .phoneNumber, .emailAddress]
            request.requiredShippingContactFields = [.postalAddress, .name, .phoneNumber, .emailAddress]
            
            // For Apple Pay Later, we need to ensure we have all the appropriate
            // merchant capabilities, especially supportsCouponCode
            request.merchantCapabilities = [.threeDSecure, .debit, .credit]
            
            // In a real implementation, Apple will automatically display
            // Apple Pay Later options in the payment sheet if available
        }
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate
extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didAuthorizePayment payment: PKPayment,
                                        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {

        
        // Simulate a network request with a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Process was successful
            let result = PKPaymentAuthorizationResult(status: .success, errors: nil)
            completion(result)
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            // The payment UI has been dismissed
            // Assuming success since we auto-approved in didAuthorizePayment
            self.paymentCompletion?(true)
            self.delegate?.didFinishPayment(success: true)
        }
    }
}

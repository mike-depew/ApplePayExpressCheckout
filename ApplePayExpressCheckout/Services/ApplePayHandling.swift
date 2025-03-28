//
//  ApplePayHandling.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/26/25.
//


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
    private var paymentCompletion: ((Bool) -> Void)?
    
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
        request.merchantIdentifier = "merchant.com.yourcompany.swiftpaydemo"
        
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
            label: "SwiftPay Demo Store",
            amount: NSDecimalNumber(decimal: subtotal + tax)
        )
        
        request.paymentSummaryItems = [subtotalItem, taxItem, totalItem]
        
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
}

// MARK: - PKPaymentAuthorizationControllerDelegate
extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, 
                                        didAuthorizePayment payment: PKPayment, 
                                        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // For the demo, we'll simulate a successful payment without actual processing
        // In a real app, you would validate the payment with your payment processor
        
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

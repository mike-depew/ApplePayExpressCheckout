//
//  ApplePayUtilityTests.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//

import XCTest
import PassKit
import ObjectiveC
@testable import ApplePayExpressCheckout

final class ApplePayUtilityTests: XCTestCase {
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        setupSwizzling()
    }
    
    override func tearDown() {
        tearDownSwizzling()
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testCanMakePayments() {
        // Given
        PKPaymentAuthorizationControllerCanMakePaymentsResult = true
        
        // When
        let result = ApplePayUtility.canMakePayments()
        
        // Then
        XCTAssertTrue(result)
        
        // Given
        PKPaymentAuthorizationControllerCanMakePaymentsResult = false
        
        // When
        let negativeResult = ApplePayUtility.canMakePayments()
        
        // Then
        XCTAssertFalse(negativeResult)
    }
    
    func testCanMakePaymentsWithNetworks() {
        // Given
        PKPaymentAuthorizationControllerCanMakePaymentsUsingNetworksResult = true
        
        // When
        let result = ApplePayUtility.canMakePaymentsWithNetworks()
        
        // Then
        XCTAssertTrue(result)
        
        // Given
        PKPaymentAuthorizationControllerCanMakePaymentsUsingNetworksResult = false
        
        // When
        let negativeResult = ApplePayUtility.canMakePaymentsWithNetworks()
        
        // Then
        XCTAssertFalse(negativeResult)
    }
    
    func testCreatePaymentRequest() {
        // Given
        let subtotal = Decimal(15.99)
        let tax = Decimal(1.60)
        
        // When
        let request = ApplePayUtility.createPaymentRequest(subtotal: subtotal, tax: tax)
        
        // Then
        XCTAssertEqual(request.merchantIdentifier, "merchant.com.yourcompany.applepayexpresscheckout")
        XCTAssertEqual(request.supportedNetworks, [.visa, .masterCard, .amex])
        XCTAssertEqual(request.merchantCapabilities, .threeDSecure)
        XCTAssertEqual(request.countryCode, "US")
        XCTAssertEqual(request.currencyCode, "USD")
        
        // Check payment summary items
        XCTAssertEqual(request.paymentSummaryItems.count, 3)
        
        // Subtotal item
        XCTAssertEqual(request.paymentSummaryItems[0].label, "Subtotal")
        XCTAssertEqual(request.paymentSummaryItems[0].amount, NSDecimalNumber(decimal: subtotal))
        
        // Tax item
        XCTAssertEqual(request.paymentSummaryItems[1].label, "Tax")
        XCTAssertEqual(request.paymentSummaryItems[1].amount, NSDecimalNumber(decimal: tax))
        
        // Total item
        XCTAssertEqual(request.paymentSummaryItems[2].label, "Express Checkout")
        XCTAssertEqual(request.paymentSummaryItems[2].amount, NSDecimalNumber(decimal: subtotal + tax))
    }
    
    // MARK: - Method Swizzling Implementations
    @objc class func swizzled_canMakePayments() -> Bool {
        return PKPaymentAuthorizationControllerCanMakePaymentsResult
    }
    
    @objc class func swizzled_canMakePaymentsUsingNetworks(_ networks: [PKPaymentNetwork]) -> Bool {
        return PKPaymentAuthorizationControllerCanMakePaymentsUsingNetworksResult
    }
}

// MARK: - Method Swizzling for Static Testing

// Variables to hold swizzled method results
private var PKPaymentAuthorizationControllerCanMakePaymentsResult = false
private var PKPaymentAuthorizationControllerCanMakePaymentsUsingNetworksResult = false

// Original method references
private var originalCanMakePaymentsMethod: Method?
private var originalCanMakePaymentsUsingNetworksMethod: Method?

extension ApplePayUtilityTests {
    // Setup method swizzling
    func setupSwizzling() {
        let pkClass = PKPaymentAuthorizationController.self
        let testClass = ApplePayUtilityTests.self
        
        // Store original method implementations
        guard let origCanMakePaymentsMethod = class_getClassMethod(pkClass,
                                              NSSelectorFromString("canMakePayments")),
              let origCanMakePaymentsWithNetworksMethod = class_getClassMethod(pkClass,
                                              NSSelectorFromString("canMakePaymentsUsingNetworks:")) else {
            print("Failed to get original methods")
            return
        }
        
        originalCanMakePaymentsMethod = origCanMakePaymentsMethod
        originalCanMakePaymentsUsingNetworksMethod = origCanMakePaymentsWithNetworksMethod
        
        // Get the swizzled method implementations
        guard let swizzledCanMakePaymentsMethod = class_getClassMethod(testClass,
                                              #selector(ApplePayUtilityTests.swizzled_canMakePayments)),
              let swizzledCanMakePaymentsUsingNetworksMethod = class_getClassMethod(testClass,
                                              #selector(ApplePayUtilityTests.swizzled_canMakePaymentsUsingNetworks)) else {
            print("Failed to get swizzled methods")
            return
        }
        
        // Perform method swizzling
        method_exchangeImplementations(origCanMakePaymentsMethod, swizzledCanMakePaymentsMethod)
        method_exchangeImplementations(origCanMakePaymentsWithNetworksMethod, swizzledCanMakePaymentsUsingNetworksMethod)
    }
    
    // Teardown method swizzling
    func tearDownSwizzling() {
        // Restore original method implementations
        if let originalMethod = originalCanMakePaymentsMethod,
           let swizzledMethod = class_getClassMethod(ApplePayUtilityTests.self,
                                    #selector(ApplePayUtilityTests.swizzled_canMakePayments)) {
            method_exchangeImplementations(swizzledMethod, originalMethod)
        }
        
        if let originalMethod = originalCanMakePaymentsUsingNetworksMethod,
           let swizzledMethod = class_getClassMethod(ApplePayUtilityTests.self,
                                    #selector(ApplePayUtilityTests.swizzled_canMakePaymentsUsingNetworks)) {
            method_exchangeImplementations(swizzledMethod, originalMethod)
        }
    }
}

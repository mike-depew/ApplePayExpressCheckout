//
//  ApplePayHandlerTests.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew
//


import XCTest
import PassKit
@testable import ApplePayExpressCheckout

final class ApplePayHandlerTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: ApplePayHandler!
    private var mockDelegate: MockApplePayHandlerDelegate!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = ApplePayHandler()
        mockDelegate = MockApplePayHandlerDelegate()
        sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        sut = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testCreatePaymentRequest() {
        // Given
        let subtotal = Decimal(10.99)
        let tax = Decimal(1.10)
        
        // When
        let request = sut.createPaymentRequest(subtotal: subtotal, tax: tax)
        
        // Then
        XCTAssertEqual(request.merchantIdentifier, "merchant.com.yourcompany.swiftpaydemo")
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
        XCTAssertEqual(request.paymentSummaryItems[2].label, "SwiftPay Demo Store")
        XCTAssertEqual(request.paymentSummaryItems[2].amount, NSDecimalNumber(decimal: subtotal + tax))
    }
    
    func testStartPayment() {
        // Given
        let subtotal = Decimal(10.99)
        let tax = Decimal(1.10)
        var paymentResult: Bool?
        
        // Mock PKPaymentAuthorizationController's present method
        class MockPKPaymentAuthorizationController: PKPaymentAuthorizationController {
            var presentCalled = false
            var mockPresentSuccess = true
            var presentCompletionHandler: ((Bool) -> Void)?
            
            override func present(completion: ( (Bool) -> Void)?) {
                presentCalled = true
                presentCompletionHandler = completion
                completion?(mockPresentSuccess)
            }
        }
        
        // Create a mock controller
        let mockController = MockPKPaymentAuthorizationController()
        
        // Inject mock controller
        sut.paymentAuthorizationController = mockController
        
        // When
        sut.startPayment(subtotal: subtotal, tax: tax) { result in
            paymentResult = result
        }
        
        // Then
        
        // Since the mock's present method immediately calls the completion,
        // we test whether the internal completion handler was set correctly
        XCTAssertNotNil(sut.paymentCompletion)
        
        // Test success callback
        sut.paymentCompletion?(true)
        XCTAssertEqual(paymentResult, true)
        
        // Reset and test failure callback
        paymentResult = nil
        sut.paymentCompletion?(false)
        XCTAssertEqual(paymentResult, false)
    }
    
    func testPaymentAuthorizationControllerDidAuthorizePayment() {
        // Create a mock payment
        let mockPayment = MockPKPayment()
        
        // Create expectation for asynchronous test
        let expectation = self.expectation(description: "Payment authorization should complete")
        
        // Call the method under test
        sut.paymentAuthorizationController(
            PKPaymentAuthorizationController(),
            didAuthorizePayment: mockPayment
        ) { result in
            // Verify successful result
            XCTAssertEqual(result.status, .success)
            // Check that errors array is empty instead of nil
            XCTAssertTrue(result.errors?.isEmpty ?? true)
            expectation.fulfill()
        }
        
        // Wait for the expectation
        waitForExpectations(timeout: 2.0)
    }
    
    func testPaymentAuthorizationControllerDidFinish() {
        // Create expectation
        let expectation = self.expectation(description: "Controller should be dismissed")
        
        // Create a mock controller that tracks dismiss calls
        class MockDismissController: PKPaymentAuthorizationController {
            var dismissCalled = false
            
            override func dismiss(completion: (() -> Void)? = nil) {
                dismissCalled = true
                completion?()
            }
        }
        
        let mockController = MockDismissController()
        
        // When
        sut.paymentAuthorizationControllerDidFinish(mockController)
        
        // Set a delay to let the async operations complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Then
            XCTAssertTrue(mockController.dismissCalled)
            XCTAssertTrue(self.mockDelegate.didFinishPaymentCalled)
            XCTAssertTrue(self.mockDelegate.paymentSuccess)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}

// MARK: - Mock Classes

class MockApplePayHandlerDelegate: ApplePayHandlerDelegate {
    var didFinishPaymentCalled = false
    var paymentSuccess = false
    
    func didFinishPayment(success: Bool) {
        didFinishPaymentCalled = true
        paymentSuccess = success
    }
}

class MockPKPayment: PKPayment {
    // Minimal implementation for testing
    // In a real test, you might need to override properties or methods used in the handler
}

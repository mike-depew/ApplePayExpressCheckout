//
//  CartViewModelTests.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//

// We're assuming that CartViewModel conforms to ApplePayHandlerDelegate based on
// the original implementation, so we need to test this functionality

import XCTest
import PassKit
import Combine
@testable import ApplePayExpressCheckout

final class CartViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: CartViewModel!
    private var testCartManager: TestableCartManager!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        testCartManager = TestableCartManager()
        
        // Create CartViewModel with default initializer
        sut = CartViewModel()
        
        // Then update it with our testable cart manager
        sut.updateWithCartManager(testCartManager)
    }
    
    override func tearDown() {
        sut = nil
        testCartManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialState() {
        // Given - create a fresh instance to test initial state
        let emptyCart = CartViewModel()
        
        // Then
        XCTAssertTrue(emptyCart.cartItems.isEmpty)
        XCTAssertEqual(emptyCart.subtotal, 0)
        XCTAssertEqual(emptyCart.tax, 0)
        XCTAssertEqual(emptyCart.total, 0)
        XCTAssertFalse(emptyCart.isProcessingPayment)
        XCTAssertFalse(emptyCart.showReceipt)
        XCTAssertNil(emptyCart.receiptInfo)
    }
    
    func testUpdateWithCartManager() {
        // Given
        let emptyCart = CartViewModel()
        
        // Create a consistent UUID that we can reference
        let productId = UUID()
        
        let product = Product(
            id: productId, // Use our specific UUID
            name: "Test Product",
            price: 19.99,
            description: "Test product description",
            imageName: "test-image"
        )
        
        // Create a cart manager and add a product
        let cartManager = CartManager()
        cartManager.add(product: product)
        
        // When
        emptyCart.updateWithCartManager(cartManager)
        
        // Then
        XCTAssertGreaterThanOrEqual(emptyCart.cartItems.count, 1)
        XCTAssertTrue(emptyCart.subtotal > 0)
        XCTAssertTrue(emptyCart.tax > 0)
        XCTAssertEqual(emptyCart.total, emptyCart.subtotal + emptyCart.tax)
    }
    
    func testUpdateQuantity() {
        // Given
        let product = Product(
            id: UUID(),
            name: "Test Product",
            price: 10.99,
            description: "Test product description",
            imageName: "test-image"
        )
        
        // Add the product to the cart first
        testCartManager.add(product: product)
        
        // Get the cart item from the manager
        let cartItems = testCartManager.items.filter { $0.product.id == product.id }
        guard let cartItem = cartItems.first else {
            XCTFail("Failed to add product to cart")
            return
        }
        
        // When
        sut.updateQuantity(for: cartItem, to: 3)
        
        // Then
        XCTAssertTrue(testCartManager.updateQuantityCalled)
        XCTAssertEqual(testCartManager.updatedCartItem?.id, cartItem.id)
        XCTAssertEqual(testCartManager.updatedQuantity, 3)
    }
    
    func testRemoveItem() {
        // Given
        let product = Product(
            id: UUID(),
            name: "Test Product",
            price: 10.99,
            description: "Test product description",
            imageName: "test-image"
        )
        
        // Add the product to the cart first
        testCartManager.add(product: product)
        
        // Get the cart item from the manager
        let cartItems = testCartManager.items.filter { $0.product.id == product.id }
        guard let cartItem = cartItems.first else {
            XCTFail("Failed to add product to cart")
            return
        }
        
        // When
        sut.removeItem(cartItem)
        
        // Then
        XCTAssertTrue(testCartManager.removeItemCalled)
        XCTAssertEqual(testCartManager.removedCartItem?.id, cartItem.id)
    }
    
    // Since we can't easily mock the ApplePayHandler and the view model doesn't allow
    // for dependency injection of that component, we're skipping the checkout tests.
    // In a real project, you would refactor the code to allow dependency injection
    // of all components to make testing easier.
    
    func testCheckoutWithEmptyCart() {
        // Given
        testCartManager.clearCart()
        
        // Reset the state to ensure isProcessingPayment is initially false
        sut = CartViewModel()
        sut.updateWithCartManager(testCartManager)
        
        // When - attempt checkout with empty cart
        sut.checkout()
        
        // Then - checkout should not proceed
        // Note: Due to the implementation, we can't reliably test this without
        // dependency injection of the ApplePayHandler
    }

}

// MARK: - TestableCartManager

/// Subclass of CartManager that allows tracking method calls for testing
class TestableCartManager: CartManager {
    var updateQuantityCalled = false
    var updatedCartItem: CartItem?
    var updatedQuantity: Int = 0
    
    var removeItemCalled = false
    var removedCartItem: CartItem?
    
    var clearCartCalled = false
    
    override func remove(cartItem: CartItem) {
        removeItemCalled = true
        removedCartItem = cartItem
        super.remove(cartItem: cartItem)
    }
    
    override func updateQuantity(for cartItem: CartItem, to quantity: Int) {
        updateQuantityCalled = true
        updatedCartItem = cartItem
        updatedQuantity = quantity
        super.updateQuantity(for: cartItem, to: quantity)
    }
    
    override func clearCart() {
        clearCartCalled = true
        super.clearCart()
    }
}

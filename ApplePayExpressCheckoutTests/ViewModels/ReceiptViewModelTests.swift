//
//  ReceiptViewModelTests.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew
//
import XCTest
@testable import ApplePayExpressCheckout

final class ReceiptViewModelTests: XCTestCase {

    // MARK: - Properties
    private var sut: ReceiptViewModel!
    private var mockReceiptInfo: ReceiptInfo!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        
        // Create mock receipt info
        let product = Product(
            id: UUID(), // Use UUID instead of String
            name: "Test Product",
            price: 19.99,
            description: "Test product description", // Also added missing description parameter
            imageName: "test-image"
        )
        let cartItem = CartItem(product: product, quantity: 2)
        
        mockReceiptInfo = ReceiptInfo(
            items: [cartItem],
            subtotal: 39.98,
            tax: 4.00,
            total: 43.98,
            shippingInfo: ShippingInfo.mockShippingInfo,
            confirmationNumber: "TEST-123456",
            purchaseDate: Date()
        )
        
        sut = ReceiptViewModel(receiptInfo: mockReceiptInfo)
    }
    
    override func tearDown() {
        sut = nil
        mockReceiptInfo = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialization() {
        // Then
        XCTAssertEqual(sut.receiptInfo.items.count, 1)
        // Use the same UUID reference from the product in setUp
        let expectedId = mockReceiptInfo.items.first?.product.id
        XCTAssertEqual(sut.receiptInfo.items.first?.product.id, expectedId)
        XCTAssertEqual(sut.receiptInfo.items.first?.quantity, 2)
        XCTAssertEqual(sut.receiptInfo.subtotal, 39.98)
        XCTAssertEqual(sut.receiptInfo.tax, 4.00)
        XCTAssertEqual(sut.receiptInfo.total, 43.98)
        XCTAssertEqual(sut.receiptInfo.confirmationNumber, "TEST-123456")
        XCTAssertFalse(sut.isSharing)
    }
    
    func testCreateReceiptPDF() {
        // When
        let pdfData = sut.createReceiptPDF()
        
        // Then
        XCTAssertNotNil(pdfData)
        
        // Basic validation of PDF content - checking size is non-zero
        if let data = pdfData {
            XCTAssertTrue(data.count > 0)
        }
        
        // Note: Testing the exact content of the PDF would require more advanced PDF parsing,
        // which is beyond the scope of unit testing. We're just verifying a PDF was created.
    }
    
    func testReceiptInfoFormattedDate() {
        // Given
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 3, day: 26, hour: 10, minute: 30))!
        
        let receiptInfoWithSpecificDate = ReceiptInfo(
            items: mockReceiptInfo.items,
            subtotal: mockReceiptInfo.subtotal,
            tax: mockReceiptInfo.tax,
            total: mockReceiptInfo.total,
            shippingInfo: mockReceiptInfo.shippingInfo,
            confirmationNumber: mockReceiptInfo.confirmationNumber,
            purchaseDate: date
        )
        
        // When
        let formattedDate = receiptInfoWithSpecificDate.formattedDate
        
        // Then
        // The exact format might depend on locale settings, but we can validate basic elements
        XCTAssertTrue(formattedDate.contains("2025"))
        XCTAssertTrue(formattedDate.contains("3") || formattedDate.contains("Mar") || formattedDate.contains("March"))
        XCTAssertTrue(formattedDate.contains("26"))
    }
    
    func testShippingInfoFormattedAddress() {
        // When
        let formattedAddress = mockReceiptInfo.shippingInfo.formattedAddress
        
        // Then
        XCTAssertTrue(formattedAddress.contains(mockReceiptInfo.shippingInfo.fullName))
        XCTAssertTrue(formattedAddress.contains(mockReceiptInfo.shippingInfo.streetAddress))
        XCTAssertTrue(formattedAddress.contains(mockReceiptInfo.shippingInfo.city))
        XCTAssertTrue(formattedAddress.contains(mockReceiptInfo.shippingInfo.state))
        XCTAssertTrue(formattedAddress.contains(mockReceiptInfo.shippingInfo.zipCode))
    }
}

// Note: In a real test suite, you might need to define these model types if they're not already imported
// We're assuming they're available through @testable import ApplePayExpressCheckout

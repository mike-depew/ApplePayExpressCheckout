//
//  TaxCalculatorTests.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//
import XCTest
@testable import ApplePayExpressCheckout

final class TaxCalculatorTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: TaxCalculator!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = TaxCalculator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testCalculateTaxWithDefaultRate() {
        // Given
        let defaultTaxRate = Constants.Tax.losAngelesSalesTaxRate
        let calculator = TaxCalculator() // Uses default rate
        let subtotal = Decimal(100.00)
        
        // Expected tax is subtotal * rate, rounded to 2 decimal places
        let expectedTax = (subtotal * defaultTaxRate).rounded(toPlaces: 2)
        
        // When
        let calculatedTax = calculator.calculateTax(forSubtotal: subtotal)
        
        // Then
        XCTAssertEqual(calculatedTax, expectedTax)
    }
    
    func testCalculateTaxWithCustomRate() {
        // Given
        let customTaxRate = Decimal(0.06) // 6% tax rate
        let calculator = TaxCalculator(taxRate: customTaxRate)
        let subtotal = Decimal(100.00)
        
        // Expected tax is subtotal * rate, rounded to 2 decimal places
        let expectedTax = Decimal(6.00) // 100 * 0.06 = 6.00
        
        // When
        let calculatedTax = calculator.calculateTax(forSubtotal: subtotal)
        
        // Then
        XCTAssertEqual(calculatedTax, expectedTax)
    }
    
    func testCalculateTaxWithZeroRate() {
        // Given
        let zeroTaxRate = Decimal(0)
        let calculator = TaxCalculator(taxRate: zeroTaxRate)
        let subtotal = Decimal(50.00)
        
        // When
        let calculatedTax = calculator.calculateTax(forSubtotal: subtotal)
        
        // Then
        XCTAssertEqual(calculatedTax, 0)
    }
    
    func testCalculateTaxWithZeroSubtotal() {
        // Given
        let subtotal = Decimal(0)
        
        // When
        let calculatedTax = sut.calculateTax(forSubtotal: subtotal)
        
        // Then
        XCTAssertEqual(calculatedTax, 0)
    }
    
    func testCalculateTaxRounding() {
        // Given
        let customTaxRate = Decimal(0.0725) // 7.25% tax rate
        let calculator = TaxCalculator(taxRate: customTaxRate)
        let subtotal = Decimal(16.99)
        
        // Expected tax is subtotal * rate, rounded to 2 decimal places
        // 16.99 * 0.0725 = 1.231775, rounded to 1.23
        let expectedTax = Decimal(1.23)
        
        // When
        let calculatedTax = calculator.calculateTax(forSubtotal: subtotal)
        
        // Then
        XCTAssertEqual(calculatedTax, expectedTax)
    }
    
    func testCalculateTotal() {
        // Given
        let customTaxRate = Decimal(0.08) // 8% tax rate
        let calculator = TaxCalculator(taxRate: customTaxRate)
        let subtotal = Decimal(25.00)
        
        // Expected total is subtotal + tax, rounded to 2 decimal places
        // Tax = 25.00 * 0.08 = 2.00
        // Total = 25.00 + 2.00 = 27.00
        let expectedTotal = Decimal(27.00)
        
        // When
        let calculatedTotal = calculator.calculateTotal(forSubtotal: subtotal)
        
        // Then
        XCTAssertEqual(calculatedTotal, expectedTotal)
    }
    
    func testCalculateTotalWithRounding() {
        // Given
        let customTaxRate = Decimal(0.0625) // 6.25% tax rate
        let calculator = TaxCalculator(taxRate: customTaxRate)
        let subtotal = Decimal(19.99)
        
        // Expected calculations:
        // Tax = 19.99 * 0.0625 = 1.249375, rounded to 1.25
        // Total = 19.99 + 1.25 = 21.24
        let expectedTotal = Decimal(21.24)
        
        // When
        let calculatedTotal = calculator.calculateTotal(forSubtotal: subtotal)
        
        // Then
        XCTAssertEqual(calculatedTotal, expectedTotal)
    }
    
    func testCalculateTotalWithZeroTax() {
        // Given
        let zeroTaxRate = Decimal(0)
        let calculator = TaxCalculator(taxRate: zeroTaxRate)
        let subtotal = Decimal(50.00)
        
        // When
        let calculatedTotal = calculator.calculateTotal(forSubtotal: subtotal)
        
        // Then
        XCTAssertEqual(calculatedTotal, subtotal)
    }
    
    // MARK: - Decimal Extension Tests
    
    func testDecimalRoundingToZeroPlaces() {
        // Given
        let value = Decimal(12.6789)
        
        // When
        let rounded = value.rounded(toPlaces: 0)
        
        // Then
        XCTAssertEqual(rounded, 13)
    }
    
    func testDecimalRoundingToTwoPlaces() {
        // Given
        let values = [
            Decimal(12.345): Decimal(12.35),   // Round up
            Decimal(12.344): Decimal(12.34),   // Round down
            Decimal(12.3): Decimal(12.30),     // Preserve trailing zeros
            Decimal(-12.345): Decimal(-12.35)  // Negative number
        ]
        
        // When & Then
        for (input, expected) in values {
            XCTAssertEqual(input.rounded(toPlaces: 2), expected)
        }
    }
}

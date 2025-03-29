//  TaxCalculating.swift
//  ApplePayExpressCheckout
//  Created by Mike Depew.

import Foundation

// Protocol defining tax calculation behavior
protocol TaxCalculating {
    func calculateTax(forSubtotal subtotal: Decimal) -> Decimal
    func calculateTotal(forSubtotal subtotal: Decimal) -> Decimal
}

// Service to calculate sales tax based on location
struct TaxCalculator: TaxCalculating {
    private let taxRate: Decimal
    
    init(taxRate: Decimal = Constants.Tax.losAngelesSalesTaxRate) {
        self.taxRate = taxRate
    }
    
    // Calculates tax amount based on subtotal
    // - Parameter subtotal: The pre-tax total
    // - Returns: The tax amount
    func calculateTax(forSubtotal subtotal: Decimal) -> Decimal {
        return (subtotal * taxRate).rounded(toPlaces: 2)
    }
    
    // Calculates the total including tax
    // - Parameter subtotal: The pre-tax total
    // - Returns: The total amount including tax
    func calculateTotal(forSubtotal subtotal: Decimal) -> Decimal {
        let tax = calculateTax(forSubtotal: subtotal)
        return (subtotal + tax).rounded(toPlaces: 2)
    }
}

// Extension to round Decimal values to specified decimal places
extension Decimal {
    func rounded(toPlaces places: Int) -> Decimal {
        // Convert the power to a Decimal value directly
        let multiplier = Decimal(pow(10.0, Double(places)))
        
        // Use NSDecimalRound for proper Decimal rounding
        var result = self * multiplier
        var roundedResult = Decimal()
        
        NSDecimalRound(&roundedResult, &result, 0, .plain)
        
        return roundedResult / multiplier
    }
}

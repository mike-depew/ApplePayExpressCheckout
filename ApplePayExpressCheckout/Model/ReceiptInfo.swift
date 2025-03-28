//
//  ReceiptInfo.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/26/25.
//
import SwiftUI

/// Model to hold receipt information
struct ReceiptInfo {
    let items: [CartItem]
    let subtotal: Decimal
    let tax: Decimal
    let total: Decimal
    let shippingInfo: ShippingInfo
    let confirmationNumber: String
    let purchaseDate: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: purchaseDate)
    }
}

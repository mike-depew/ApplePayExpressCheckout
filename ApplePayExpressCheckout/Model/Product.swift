//
//  Product.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/26/25.
//


import Foundation

/// Model representing a product in the catalog
struct Product: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let price: Decimal
    let description: String
    let imageName: String
    
    init(id: UUID = UUID(), name: String, price: Decimal, description: String, imageName: String) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.imageName = imageName
    }
    
    // Conformance to Equatable
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// A CartItem represents a product with a quantity
struct CartItem: Identifiable, Equatable {
    let id: UUID
    let product: Product
    var quantity: Int
    
    init(id: UUID = UUID(), product: Product, quantity: Int = 1) {
        self.id = id
        self.product = product
        self.quantity = quantity
    }
    
    var subtotal: Decimal {
        return product.price * Decimal(quantity)
    }
    
    // Conformance to Equatable
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.id == rhs.id
    }
}
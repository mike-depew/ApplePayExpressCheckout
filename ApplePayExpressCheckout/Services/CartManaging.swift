//  CartManaging.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.

import Foundation
import Combine

// Protocol defining shopping cart operations
protocol CartManaging {
    var items: [CartItem] { get }
    var itemsPublisher: Published<[CartItem]>.Publisher { get }
    var subtotal: Decimal { get }
    
    func add(product: Product)
    func remove(cartItem: CartItem)
    func updateQuantity(for cartItem: CartItem, to quantity: Int)
    func clearCart()
    func contains(product: Product) -> Bool
    func quantity(for product: Product) -> Int
}

// Manages the shopping cart state and operations
class CartManager: CartManaging, ObservableObject {
    @Published private(set) var items: [CartItem] = []
    
    var itemsPublisher: Published<[CartItem]>.Publisher { $items }
    
    var subtotal: Decimal {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    // Adds a product to the cart or increments quantity if already in cart
    // - Parameter product: The product to add
    func add(product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            let item = items[index]
            items[index] = CartItem(id: item.id, product: product, quantity: item.quantity + 1)
        } else {
            items.append(CartItem(product: product))
        }
    }
    
    // Removes an item from the cart completely
    // - Parameter cartItem: The cart item to remove
    func remove(cartItem: CartItem) {
        items.removeAll { $0.id == cartItem.id }
    }
    
    // Updates the quantity of a specific cart item
    // - Parameters:
    //   - cartItem: The cart item to update
    //   - quantity: The new quantity (if 0, item is removed)
    func updateQuantity(for cartItem: CartItem, to quantity: Int) {
        guard quantity > 0 else {
            remove(cartItem: cartItem)
            return
        }
        
        if let index = items.firstIndex(where: { $0.id == cartItem.id }) {
            items[index] = CartItem(id: cartItem.id, product: cartItem.product, quantity: quantity)
        }
    }
    
    // Removes all items from the cart
    func clearCart() {
        items.removeAll()
    }
    
    // Checks if a product is already in the cart
    // - Parameter product: The product to check
    // - Returns: True if the product is in the cart
    func contains(product: Product) -> Bool {
        items.contains { $0.product.id == product.id }
    }
    
    // Gets the quantity of a specific product in the cart
    // - Parameter product: The product to check
    // - Returns: The quantity (0 if not in cart)
    func quantity(for product: Product) -> Int {
        guard let item = items.first(where: { $0.product.id == product.id }) else {
            return 0
        }
        return item.quantity
    }
}

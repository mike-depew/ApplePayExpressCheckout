//
//  ApplePayExpressCheckoutApp.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/26/25.
//

import SwiftUI

@main
struct ApplePayExpressCheckoutApp: App {
    // Create shared instances that will be used across the app
    @StateObject private var cartManager = CartManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(cartManager)
                .preferredColorScheme(.dark) // Set the app to use dark mode
                .accentColor(Constants.Theme.accentColor)
        }
    }
}

//
//  ApplePayButton.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.

import SwiftUI
import PassKit

// Custom Apple Pay button with loading state and Apple Pay Later support

struct ApplePayButton: View {
    // MARK: - Properties
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    let showApplePayLater: Bool
    let amount: Double
    
    // MARK: - Initialization
    init(isEnabled: Bool, isLoading: Bool, action: @escaping () -> Void, showApplePayLater: Bool = false, amount: Double = 0.0) {
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
        self.showApplePayLater = showApplePayLater
        self.amount = amount
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                if isEnabled && !isLoading {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    action()
                }
            }) {
                ZStack {
                    // Apple Pay Button Background
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    
                    if isLoading {
                        // Loading Indicator
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    } else {
                        // Apple Pay Logo and Text
                        HStack(spacing: 8) {
                            Image(systemName: "applelogo")
                                .font(.system(size: 20))
                            
                            Text("Pay")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .frame(height: Constants.Layout.buttonHeight)
            .disabled(!isEnabled || isLoading)
            .opacity(isEnabled ? 1.0 : 0.6)
            .overlay(
                Group {
                    if !isEnabled && !isLoading {
                        VStack {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 16))
                            Text("Apple Pay Unavailable")
                                .font(.caption2)
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                })
            
            // Apple Pay Later information (conditionally displayed)
            if showApplePayLater && isEnabled && amount > 0 {
                applePayLaterInfo
            }
        }
    }
    
    // MARK: - Apple Pay Later Info View
    private var applePayLaterInfo: some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Pay in 4 interest-free payments")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if amount > 0 {
                Text("\(formatAmount(amount / 4)) every 2 weeks")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Helper Methods
    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // You might want to make this configurable
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

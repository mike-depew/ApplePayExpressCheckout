//
//  ApplePayButton.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.

import SwiftUI
import PassKit

/// Custom Apple Pay button with loading state
struct ApplePayButton: View {
    // MARK: - Properties
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
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
            })}}

//
//  QuantitySelector.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//


import SwiftUI

/// Reusable component for selecting quantity
struct QuantitySelector: View {
    // MARK: - Properties
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {
            // Decrement Button
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Constants.Theme.accentColor.opacity(0.8))
                    .cornerRadius(Constants.Layout.cornerRadius / 2)
            }
            
            // Quantity Display
            Text("\(quantity)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Constants.Theme.textColor)
                .frame(minWidth: 30)
                .multilineTextAlignment(.center)
            
            // Increment Button
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Constants.Theme.accentColor)
                    .cornerRadius(Constants.Layout.cornerRadius / 2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct QuantitySelector_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            QuantitySelector(quantity: 1, onIncrement: {}, onDecrement: {})
            QuantitySelector(quantity: 5, onIncrement: {}, onDecrement: {})
        }
        .padding()
        .background(Constants.Theme.backgroundColor)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}

//
//  OrderSummary.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/26/25.
//


import SwiftUI

/// Component to display order summary information
struct OrderSummary: View {
    // MARK: - Properties
    let subtotal: Decimal
    let tax: Decimal
    let total: Decimal
    var showShipping: Bool = true
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Constants.Layout.spacing / 2) {
            HStack {
                Text("Order Summary")
                    .font(.headline)
                    .foregroundColor(Constants.Theme.textColor)
                Spacer()
            }
            .padding(.bottom, 4)
            
            // Summary Lines
            VStack(spacing: 8) {
                SummaryRow(title: "Subtotal", value: subtotal)
                
                if showShipping {
                    SummaryRow(title: "Shipping", value: "Free", valueColor: .green)
                }
                
                SummaryRow(title: "Tax", value: tax)
                
                Divider()
                    .background(Constants.Theme.secondaryTextColor)
                    .padding(.vertical, 4)
                
                SummaryRow(
                    title: "Total",
                    value: total,
                    titleWeight: .bold,
                    valueWeight: .bold,
                    titleSize: .callout,
                    valueSize: .callout
                )
            }
        }
        .padding()
        .background(Constants.Theme.cardColor)
    }
}

/// Individual row in the order summary
struct SummaryRow<V>: View {
    // MARK: - Properties
    let title: String
    let value: V
    var titleWeight: Font.Weight = .regular
    var valueWeight: Font.Weight = .semibold
    var titleSize: Font = .subheadline
    var valueSize: Font = .subheadline
    var titleColor: Color = Constants.Theme.secondaryTextColor
    var valueColor: Color = Constants.Theme.textColor
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text(title)
                .font(titleSize)
                .fontWeight(titleWeight)
                .foregroundColor(titleColor)
            
            Spacer()
            
            if let decimalValue = value as? Decimal {
                Text(decimalValue.asCurrencyString())
                    .font(valueSize)
                    .fontWeight(valueWeight)
                    .foregroundColor(valueColor)
            } else if let stringValue = value as? String {
                Text(stringValue)
                    .font(valueSize)
                    .fontWeight(valueWeight)
                    .foregroundColor(valueColor)
            }
        }
    }
}

// MARK: - Preview
struct OrderSummary_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OrderSummary(
                subtotal: 94.00,
                tax: 8.93,
                total: 102.93
            )
            
            OrderSummary(
                subtotal: 124.00,
                tax: 11.78,
                total: 135.78,
                showShipping: false
            )
        }
        .padding()
        .background(Constants.Theme.backgroundColor)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
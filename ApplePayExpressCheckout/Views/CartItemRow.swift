//
//  CartItemRow.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/30/25.
//

import SwiftUI

struct CartItemRow: View {
    // MARK: - Properties
    let item: CartItem
    var onUpdateQuantity: (Int) -> Void
    var onRemove: () -> Void
    
    @State private var showQuantityPicker = false
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Main item row
            HStack(alignment: .center, spacing: 12) {
                // Product image
                Image(item.product.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
                
                // Product details
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.product.name)
                        .font(.headline)
                        .foregroundColor(Constants.Theme.textColor)
                    
                    // Price row
                    HStack {
                        Text(item.product.price.asCurrencyString())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Theme.accentColor)
                        
                        Spacer()
                        
                        // Quantity with update button
                        Button(action: {
                            showQuantityPicker.toggle()
                        }) {
                            HStack(spacing: 4) {
                                Text("Qty: \(item.quantity)")
                                    .font(.subheadline)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                // Subtotal and remove button
                VStack(alignment: .trailing, spacing: 8) {
                    Text(item.subtotal.asCurrencyString())
                        .font(.headline)
                        .foregroundColor(Constants.Theme.textColor)
                    
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(Color.red)
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Constants.Theme.cardColor)
            .cornerRadius(Constants.Layout.cornerRadius)
            
            // Quantity picker
            if showQuantityPicker {
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach([1, 2, 3, 4, 5], id: \.self) { quantity in
                        Button(action: {
                            onUpdateQuantity(quantity)
                            showQuantityPicker = false
                        }) {
                            Text("\(quantity)")
                                .font(.subheadline)
                                .fontWeight(item.quantity == quantity ? .bold : .regular)
                                .foregroundColor(item.quantity == quantity ? Constants.Theme.accentColor : Constants.Theme.textColor)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(item.quantity == quantity ? Constants.Theme.accentColor.opacity(0.1) : Color.clear)
                        .cornerRadius(4)
                    }
                    
                    Button(action: {
                        onRemove()
                        showQuantityPicker = false
                    }) {
                        Text("Remove")
                            .font(.subheadline)
                            .foregroundColor(Color.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
                }
                .padding()
                .background(Constants.Theme.cardColor)
                .cornerRadius(Constants.Layout.cornerRadius)
                .transition(.opacity)
                .animation(.easeInOut, value: showQuantityPicker)
            }
        }
    }
}

// MARK: - Preview
struct CartItemRow_Previews: PreviewProvider {
    static var previews: some View {
        let mockProduct = Product(
            id: UUID(),
            name: "Product Name",
            price: Decimal(29.99),
            description: "Product description",
            imageName: "productImage"
        )
        
        let mockItem = CartItem(
            product: mockProduct,
            quantity: 2
        )
        
        return CartItemRow(
            item: mockItem,
            onUpdateQuantity: { _ in },
            onRemove: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

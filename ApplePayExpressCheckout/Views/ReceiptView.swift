//
//  ReceiptView.swift
//  ApplePayExpressCheckout
//
//  Created by Mike Depew.
//


import SwiftUI

/// View for displaying the receipt after a successful purchase
struct ReceiptView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ReceiptViewModel
    @Binding var isPresented: Bool
    @State private var showShareSheet = false
    @State private var receiptPDF: Data?
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background color
            Constants.Theme.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header
                HStack {
                    Spacer()
                    
                    Text("Order Confirmation")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Theme.textColor)
                    
                    Spacer()
                }
                .overlay(
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(Constants.Theme.secondaryTextColor)
                    }
                    .padding()
                    , alignment: .trailing
                )
                .padding(.vertical)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Success Banner
                        successBanner
                        
                        // Order Details
                        orderDetailsSection
                        
                        // Items Purchased
                        itemsSection
                        
                        // Shipping Info
                        shippingInfoSection
                        
                        // Payment Summary
                        paymentSummarySection
                        
                        // Share Button
                        shareButton
                            .padding(.top, 16)
                    }
                    .padding()
                }
                
                // Continue Shopping Button
                continueShoppingButton
                    .padding()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let receiptPDF = receiptPDF {
                ShareSheet(items: [receiptPDF])
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Banner showing success message
    private var successBanner: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Thank you for your purchase!")
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Constants.Theme.textColor)
            
            Text("Your order has been confirmed")
                .font(.subheadline)
                .foregroundColor(Constants.Theme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Constants.Theme.cardColor)
        .cornerRadius(Constants.Layout.cornerRadius)
    }
    
    /// Section with order details (confirmation number, date)
    private var orderDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Details")
                .font(.headline)
                .foregroundColor(Constants.Theme.textColor)
            
            VStack(alignment: .leading, spacing: 8) {
                detailRow(
                    label: "Confirmation Number",
                    value: viewModel.receiptInfo.confirmationNumber
                )
                
                detailRow(
                    label: "Order Date",
                    value: viewModel.receiptInfo.formattedDate
                )
            }
            .padding()
            .background(Constants.Theme.cardColor)
            .cornerRadius(Constants.Layout.cornerRadius)
        }
    }
    
    /// Section with items purchased
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Items")
                .font(.headline)
                .foregroundColor(Constants.Theme.textColor)
            
            VStack(spacing: 12) {
                ForEach(viewModel.receiptInfo.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product.name)
                                .font(.subheadline)
                                .foregroundColor(Constants.Theme.textColor)
                            
                            Text("\(item.quantity) × \(item.product.price.asCurrencyString())")
                                .font(.caption)
                                .foregroundColor(Constants.Theme.secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        Text(item.subtotal.asCurrencyString())
                            .font(.subheadline)
                            .foregroundColor(Constants.Theme.textColor)
                    }
                    .padding(.vertical, 4)
                    
                    if item.id != viewModel.receiptInfo.items.last?.id {
                        Divider()
                            .background(Constants.Theme.secondaryTextColor.opacity(0.3))
                    }
                }
            }
            .padding()
            .background(Constants.Theme.cardColor)
            .cornerRadius(Constants.Layout.cornerRadius)
        }
    }
    
    /// Section with shipping information
    private var shippingInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shipping Address")
                .font(.headline)
                .foregroundColor(Constants.Theme.textColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.receiptInfo.shippingInfo.fullName)
                    .font(.subheadline)
                    .foregroundColor(Constants.Theme.textColor)
                
                Text(viewModel.receiptInfo.shippingInfo.streetAddress)
                    .font(.caption)
                    .foregroundColor(Constants.Theme.secondaryTextColor)
                
                Text("\(viewModel.receiptInfo.shippingInfo.city), \(viewModel.receiptInfo.shippingInfo.state) \(viewModel.receiptInfo.shippingInfo.zipCode)")
                    .font(.caption)
                    .foregroundColor(Constants.Theme.secondaryTextColor)
                
                Text(viewModel.receiptInfo.shippingInfo.country)
                    .font(.caption)
                    .foregroundColor(Constants.Theme.secondaryTextColor)
                
                Text(viewModel.receiptInfo.shippingInfo.phoneNumber)
                    .font(.caption)
                    .foregroundColor(Constants.Theme.secondaryTextColor)
                    .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Constants.Theme.cardColor)
            .cornerRadius(Constants.Layout.cornerRadius)
        }
    }
    
    /// Section with payment summary
    private var paymentSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Summary")
                .font(.headline)
                .foregroundColor(Constants.Theme.textColor)
            
            OrderSummary(
                subtotal: viewModel.receiptInfo.subtotal,
                tax: viewModel.receiptInfo.tax,
                total: viewModel.receiptInfo.total
            )
            .background(Constants.Theme.cardColor)
            .cornerRadius(Constants.Layout.cornerRadius)
        }
    }
    
    /// Button to share receipt
    private var shareButton: some View {
        Button(action: {
            // Generate PDF
            receiptPDF = viewModel.createReceiptPDF()
            
            // Show share sheet
            showShareSheet = true
        }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
                
                Text("Share Receipt")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Constants.Theme.accentColor)
            .cornerRadius(Constants.Layout.cornerRadius)
        }
    }
    
    /// Button to continue shopping
    private var continueShoppingButton: some View {
        Button(action: {
            // Close receipt and return to shopping
            isPresented = false
        }) {
            Text("Continue Shopping")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Theme.accentColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .stroke(Constants.Theme.accentColor, lineWidth: 2)
                )
        }
    }
    
    /// Helper function to create detail rows
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundColor(Constants.Theme.secondaryTextColor)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(Constants.Theme.textColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// A sheet for sharing content
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update
    }
}

// MARK: - Preview
struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        let mockItems = [
            CartItem(product: Constants.MockData.products[0], quantity: 2),
            CartItem(product: Constants.MockData.products[2], quantity: 1)
        ]
        
        let receiptInfo = ReceiptInfo(
            items: mockItems,
            subtotal: 59.00,
            tax: 5.61,
            total: 64.61,
            shippingInfo: ShippingInfo.mockShippingInfo,
            confirmationNumber: "SWIFT-123456",
            purchaseDate: Date()
        )
        
        return ReceiptView(
            viewModel: ReceiptViewModel(receiptInfo: receiptInfo),
            isPresented: .constant(true)
        )
        .preferredColorScheme(.dark)
    }
}

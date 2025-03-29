//  ReceiptViewModel.swift
//  ApplePayExpressCheckout
//  Created by Mike Depew.

import Foundation
import UIKit
import SwiftUI

//  This ViewModel is responsible for handling the transaction receipt logic.

class ReceiptViewModel: ObservableObject {
    // MARK: - Properties
    let receiptInfo: ReceiptInfo
    
    @Published var isSharing = false
    
    // MARK: - Initializer
    init(receiptInfo: ReceiptInfo) {
        self.receiptInfo = receiptInfo
    }
    
    // MARK: - Public Methods
    
    /// Creates a shareable PDF of the receipt
    /// - Returns: Data containing the PDF
    func createReceiptPDF() -> Data? {
        let pageWidth: CGFloat = 8.5 * 72.0 // 8.5 inches in points
        let pageHeight: CGFloat = 11.0 * 72.0 // 11 inches in points
        _ = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50
        
        // Create the PDF context
        let pdfData = NSMutableData()
        
        // Create a mutable copy of the page rect that can be passed as inout
        var mediaBox = CGRect(origin: .zero, size: CGSize(width: pageWidth, height: pageHeight))
        
        guard let pdfContext = CGContext(consumer: CGDataConsumer(data: pdfData as CFMutableData)!, mediaBox: &mediaBox, nil) else {
            return nil
        }
        
        // Start a new PDF page
        pdfContext.beginPDFPage(nil)
        
        // Set up drawing parameters
        let textColor = UIColor.black
        let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        let subtitleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let bodyFont = UIFont.systemFont(ofSize: 14)
        
        // Draw title
        let titleAttributes = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        
        let title = "Receipt"
        let titleSize = title.size(withAttributes: titleAttributes)
        title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)
        
        // Draw confirmation number
        let confirmationAttributes = [
            NSAttributedString.Key.font: subtitleFont,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        
        let confirmationText = "Confirmation #: \(receiptInfo.confirmationNumber)"
        confirmationText.draw(at: CGPoint(x: margin, y: margin + titleSize.height + 20), withAttributes: confirmationAttributes)
        
        // Draw date
        let dateText = "Date: \(receiptInfo.formattedDate)"
        dateText.draw(at: CGPoint(x: margin, y: margin + titleSize.height + 45), withAttributes: confirmationAttributes)
        
        // Draw shipping address
        let addressTitle = "Shipping Address:"
        addressTitle.draw(at: CGPoint(x: margin, y: margin + titleSize.height + 80), withAttributes: confirmationAttributes)
        
        let addressAttributes = [
            NSAttributedString.Key.font: bodyFont,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        
        let addressLines = receiptInfo.shippingInfo.formattedAddress.components(separatedBy: "\n")
        for (index, line) in addressLines.enumerated() {
            line.draw(
                at: CGPoint(x: margin, y: margin + titleSize.height + 105 + CGFloat(index) * 18),
                withAttributes: addressAttributes
            )
        }
        
        // Draw line items header
        let lineY = margin + titleSize.height + 190
        pdfContext.move(to: CGPoint(x: margin, y: lineY))
        pdfContext.addLine(to: CGPoint(x: pageWidth - margin, y: lineY))
        pdfContext.setStrokeColor(UIColor.gray.cgColor)
        pdfContext.strokePath()
        
        let headerY = lineY + 20
        let itemHeaderText = "Item"
        let qtyHeaderText = "Qty"
        let priceHeaderText = "Price"
        let totalHeaderText = "Total"
        
        let col1X = margin
        let col2X = pageWidth - margin - 150
        let col3X = pageWidth - margin - 100
        let col4X = pageWidth - margin - 50
        
        itemHeaderText.draw(at: CGPoint(x: col1X, y: headerY), withAttributes: confirmationAttributes)
        qtyHeaderText.draw(at: CGPoint(x: col2X, y: headerY), withAttributes: confirmationAttributes)
        priceHeaderText.draw(at: CGPoint(x: col3X, y: headerY), withAttributes: confirmationAttributes)
        totalHeaderText.draw(at: CGPoint(x: col4X, y: headerY), withAttributes: confirmationAttributes)
        
        // Draw items
        var currentY = headerY + 30
        for item in receiptInfo.items {
            let itemName = item.product.name
            let qtyText = "\(item.quantity)"
            let priceText = item.product.price.asCurrencyString()
            let itemTotalText = item.subtotal.asCurrencyString()
            
            itemName.draw(at: CGPoint(x: col1X, y: currentY), withAttributes: addressAttributes)
            qtyText.draw(at: CGPoint(x: col2X, y: currentY), withAttributes: addressAttributes)
            priceText.draw(at: CGPoint(x: col3X, y: currentY), withAttributes: addressAttributes)
            itemTotalText.draw(at: CGPoint(x: col4X, y: currentY), withAttributes: addressAttributes)
            
            currentY += 25
        }
        
        // Draw bottom line
        let bottomLineY = currentY + 10
        pdfContext.move(to: CGPoint(x: margin, y: bottomLineY))
        pdfContext.addLine(to: CGPoint(x: pageWidth - margin, y: bottomLineY))
        pdfContext.setStrokeColor(UIColor.gray.cgColor)
        pdfContext.strokePath()
        
        // Draw summary
        currentY = bottomLineY + 30
        
        let summaryAttributes = [
            NSAttributedString.Key.font: bodyFont,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        
        let summaryBoldAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold),
            NSAttributedString.Key.foregroundColor: textColor
        ]
        
        // Subtotal
        "Subtotal:".draw(at: CGPoint(x: pageWidth - margin - 150, y: currentY), withAttributes: summaryAttributes)
        receiptInfo.subtotal.asCurrencyString().draw(at: CGPoint(x: pageWidth - margin - 50, y: currentY), withAttributes: summaryAttributes)
        currentY += 25
        
        // Tax
        "Tax:".draw(at: CGPoint(x: pageWidth - margin - 150, y: currentY), withAttributes: summaryAttributes)
        receiptInfo.tax.asCurrencyString().draw(at: CGPoint(x: pageWidth - margin - 50, y: currentY), withAttributes: summaryAttributes)
        currentY += 25
        
        // Shipping
        "Shipping:".draw(at: CGPoint(x: pageWidth - margin - 150, y: currentY), withAttributes: summaryAttributes)
        "Free".draw(at: CGPoint(x: pageWidth - margin - 50, y: currentY), withAttributes: summaryAttributes)
        currentY += 25
        
        // Total
        pdfContext.move(to: CGPoint(x: pageWidth - margin - 150, y: currentY))
        pdfContext.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
        pdfContext.setStrokeColor(UIColor.gray.cgColor)
        pdfContext.strokePath()
        currentY += 10
        
        "Total:".draw(at: CGPoint(x: pageWidth - margin - 150, y: currentY), withAttributes: summaryBoldAttributes)
        receiptInfo.total.asCurrencyString().draw(at: CGPoint(x: pageWidth - margin - 50, y: currentY), withAttributes: summaryBoldAttributes)
        
        // Draw thank you message
        let thankYouText = "Thank you for your purchase!"
        let thankYouAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor: textColor
        ]
        
        let thankYouSize = thankYouText.size(withAttributes: thankYouAttributes)
        thankYouText.draw(
            at: CGPoint(x: (pageWidth - thankYouSize.width) / 2, y: pageHeight - margin - thankYouSize.height),
            withAttributes: thankYouAttributes
        )
        
        // End the PDF page and close the context
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        return pdfData as Data
    }
}

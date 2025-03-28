//
//  ShippingInfo.swift
//  ApplePayExpressCheckout
//
//  Created by Admin on 3/26/25.
//


import Foundation

/// Model representing shipping information
struct ShippingInfo: Identifiable {
    let id: UUID
    let fullName: String
    let streetAddress: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let phoneNumber: String
    
    init(
        id: UUID = UUID(),
        fullName: String,
        streetAddress: String,
        city: String,
        state: String,
        zipCode: String,
        country: String,
        phoneNumber: String
    ) {
        self.id = id
        self.fullName = fullName
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.phoneNumber = phoneNumber
    }
    
    /// Returns the formatted address as a single string
    var formattedAddress: String {
        return """
        \(fullName)
        \(streetAddress)
        \(city), \(state) \(zipCode)
        \(country)
        \(phoneNumber)
        """
    }
    
    /// Returns a mock shipping info for demo purposes
    static var mockShippingInfo: ShippingInfo {
        ShippingInfo(
            fullName: "Alex Johnson",
            streetAddress: "123 Tech Boulevard",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90210",
            country: "United States",
            phoneNumber: "(310) 555-1234"
        )
    }
}
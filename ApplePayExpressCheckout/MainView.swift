//
//  MainView.swift
//  ApplePayExpressCheckout

//  Creatd by Mike Depew.

import SwiftUI

// The main container view that manages navigation between tabs
struct MainView: View {
    // MARK: - Properties
    @EnvironmentObject private var cartManager: CartManager
    @StateObject private var cartViewModel = CartViewModel()
    @State private var selectedTab = 0
    @State private var showReceipt = false
    @State private var receiptInfo: ReceiptInfo?
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background color
            Constants.Theme.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                // Catalog Tab
                NavigationView {
                    CatalogView()
                        .navigationTitle("Catalog")
                        .environmentObject(cartManager)
                }
                .tabItem {
                    Label("Shop", systemImage: "bag")
                }
                .tag(0)
                
                // Cart Tab
                NavigationView {
                    ShoppingCartView(
                        viewModel: cartViewModel,
                        showReceipt: $showReceipt,
                        receiptInfo: $receiptInfo
                    )
                    .navigationTitle("Cart")
                    .environmentObject(cartManager)
                    .onAppear {
                        // Update the view model with the latest cart data
                        cartViewModel.updateWithCartManager(cartManager)
                    }
                }
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .tag(1)
                .badge(cartManager.totalItems > 0 ? cartManager.totalItems : 0)
            }
            .accentColor(Constants.Theme.accentColor)
            
            // Present receipt as a full-screen modal when payment is completed
            if showReceipt, let receiptInfo = receiptInfo {
                ReceiptView(
                    viewModel: ReceiptViewModel(receiptInfo: receiptInfo),
                    isPresented: $showReceipt
                )
                .transition(.move(edge: .bottom))
                .zIndex(1) // Ensure receipt view is on top
                .onDisappear {
                    // Reset receipt info when the receipt view is dismissed
                    self.receiptInfo = nil
                }
            }
        }
        // Watch for changes in the cart view model
        .onAppear {
            setupBindings()
        }
        // When showing receipt is toggled off, clean everything up
        .onChange(of: showReceipt) { oldValue, newValue in
            if !newValue {
                // If receipt was just dismissed, reset receipt info to prevent it from reappearing
                self.receiptInfo = nil
                
                // Also ensure the cartViewModel's receiptInfo is cleared
                if cartViewModel.receiptInfo != nil {
                    cartViewModel.receiptInfo = nil
                }
            }
        }
    }
    
    // Set up bindings to monitor changes to cartViewModel.receiptInfo
    private func setupBindings() {
        // Remove any existing cancellables to avoid duplicate bindings
        cartViewModel.cancellables.removeAll()
        
        cartViewModel.$receiptInfo
            .compactMap { $0 }  // Filter out nil values
            .sink { newReceiptInfo in
                // Only show receipt if we don't already have one displayed
                if self.receiptInfo == nil {
                    self.receiptInfo = newReceiptInfo
                    self.showReceipt = true
                }
            }
            .store(in: &cartViewModel.cancellables)
    }
}

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(CartManager())
            .preferredColorScheme(.dark)
    }
}

// MARK: - View Extension for handling Optional changes
extension View {
    // Alternative to onChange for optional values that might not be Equatable
    func onReceiptInfoChange<T>(_ value: Binding<T?>, perform action: @escaping (T?) -> Void) -> some View {
        self.onChange(of: value.wrappedValue != nil) { oldValue, newValue in
            if newValue {
                action(value.wrappedValue)
            }
        }
    }
}

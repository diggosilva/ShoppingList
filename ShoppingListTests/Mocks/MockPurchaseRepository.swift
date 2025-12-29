//
//  MockPurchaseRepository.swift
//  ShoppingListTests
//
//  Created by Diggo Silva on 29/12/25.
//

@testable import ShoppingList

final class MockPurchaseRepository: PurchaseRepositoryProtocol {
    
    private(set) var savedPurchases: [Purchase] = []
    var purchasesToLoad: [Purchase] = []
    
    func loadPurchases() -> [Purchase] {
        return purchasesToLoad
    }
    
    func savePurchases(_ purchases: [Purchase]) {
        savedPurchases = purchases
    }
}

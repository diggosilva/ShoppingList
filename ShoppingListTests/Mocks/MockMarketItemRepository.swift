//
//  MockMarketItemRepository.swift
//  ShoppingListTests
//
//  Created by Diggo Silva on 28/12/25.
//

@testable import ShoppingList

final class MockMarketItemRepository: MarketItemRepositoryProtocol {
    
    private(set) var savedItems: [MarketItem] = []
    var itemsToLoad: [MarketItem] = []
    
    func loadItems() -> [MarketItem] {
        return itemsToLoad
    }
    
    func saveItems(_ items: [MarketItem]) {
        savedItems = items
    }
}

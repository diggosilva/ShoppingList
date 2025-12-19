//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by Diggo Silva on 18/12/25.
//

import Foundation

protocol ShoppingListViewModelProtocol: AnyObject {
    func numberOfRows() -> Int
    func itemForRow(at index: Int) -> MarketItem
    func updateQuantity(itemID: UUID, quantity: Int)
    func addItem(_ item: MarketItem)
    func removeItem(at index: Int)
    func totalValue() -> Double
}

final class ShoppingListViewModel: ShoppingListViewModelProtocol {
    
    private var marketItems: [MarketItem] = []
    private let repository: RepositoryProtocol
    
    init(repository: RepositoryProtocol = Repository()) {
        self.repository = repository
    }
    
    func numberOfRows() -> Int {
        return marketItems.count
    }
    
    func itemForRow(at index: Int) -> MarketItem {
        return marketItems[index]
    }
    
    func updateQuantity(itemID: UUID, quantity: Int) {
        if let index = marketItems.firstIndex(where: { $0.id == itemID }) {
            let oldItem = marketItems[index]
            let updatedItem = MarketItem(name: oldItem.name, unitPrice: oldItem.unitPrice, quantity: quantity)
            
            marketItems.append(updatedItem)
            repository.saveItems(marketItems)
        }
    }
    
    func addItem(_ item: MarketItem) {
        marketItems.append(item)
        repository.saveItems(marketItems)
    }
    
    func removeItem(at index: Int) {
        guard marketItems.indices.contains(index) else { return }
        marketItems.remove(at: index)
        repository.saveItems(marketItems)
    }
    
    func totalValue() -> Double {
        return marketItems.reduce(0) { total, item in
            total + (item.unitPrice * Double(item.quantity))
        }
    }
}

//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by Diggo Silva on 18/12/25.
//

import Foundation

protocol ShoppingListViewModelProtocol: AnyObject {
    var onDataChanged: (() -> Void)? { get set }
    var totalPurchaseValue: Double { get }
    var totalItems: Int { get }
    var totalQuantity: Int { get }
    
    func loadItems()
    func numberOfRows() -> Int
    func itemForRow(at index: Int) -> MarketItem
    func updateQuantity(itemID: UUID, quantity: Int)
    func updateItem(_ item: MarketItem)
    func addItem(_ item: MarketItem)
    func removeItem(at index: Int)
    func finalizePurchase() -> Purchase
    func clearItems()
}

final class ShoppingListViewModel: ShoppingListViewModelProtocol {
    
    private var marketItems: [MarketItem] = []
    private let repository: MarketItemRepositoryProtocol
    
    var onDataChanged: (() -> Void)?
    
    var totalPurchaseValue: Double {
        return marketItems.reduce(0) { $0 + $1.totalValue }
    }
    
    var totalItems: Int {
        return marketItems.count
    }
    
    var totalQuantity: Int {
        return marketItems.reduce(0) { $0 + $1.quantity }
    }
    
    init(repository: MarketItemRepositoryProtocol = MarketItemRepository()) {
        self.repository = repository
        loadItems()
    }
    
    func loadItems() {
        marketItems = repository.loadItems()
        onDataChanged?()
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
            let updatedItem = MarketItem(id: oldItem.id, name: oldItem.name, unitPrice: oldItem.unitPrice, quantity: quantity)
            marketItems[index] = updatedItem
            repository.saveItems(marketItems)
            onDataChanged?()
        }
    }
    
    func updateItem(_ item: MarketItem) {
        guard let index = marketItems.firstIndex(where: { $0.id == item.id }) else { return }
        marketItems[index] = item
        repository.saveItems(marketItems)
        onDataChanged?()
    }
    
    func addItem(_ item: MarketItem) {
        marketItems.insert(item, at: 0)
        repository.saveItems(marketItems)
        onDataChanged?()
    }
    
    func removeItem(at index: Int) {
        guard marketItems.indices.contains(index) else { return }
        marketItems.remove(at: index)
        repository.saveItems(marketItems)
        onDataChanged?()
    }
    
    func finalizePurchase() -> Purchase {
        return Purchase(items: marketItems)
    }
    
    func clearItems() {
        marketItems.removeAll()
        repository.saveItems([])
        onDataChanged?()
    }
}

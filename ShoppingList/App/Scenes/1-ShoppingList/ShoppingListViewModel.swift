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
    var totalQuantityUnits: Int { get }
    var totalQuantityWeight: Double { get }
    var marketItemsForView: [MarketItem] { get }
    
    func loadItems()
    func numberOfRows() -> Int
    func itemForRow(at index: Int) -> MarketItem
    func updateQuantity(itemID: UUID, quantity: Int)
    func updateItem(_ item: MarketItem)
    func addItem(_ item: MarketItem)
    func removeItem(at index: Int)
    func finalizePurchase() -> Purchase
    func clearItems()
    func search(text: String)
}

final class ShoppingListViewModel: ShoppingListViewModelProtocol {
    
    private var marketItems: [MarketItem] = []
    private var filteredMarketItems: [MarketItem] = []
    private var currentSearchText: String = ""
    
    private let repository: MarketItemRepositoryProtocol
    
    var onDataChanged: (() -> Void)?
    
    var totalPurchaseValue: Double {
        return marketItems.reduce(0) { $0 + $1.totalValue }
    }
    
    var totalItems: Int {
        return marketItems.count
    }
    
    // Soma apenas unidades
    var totalQuantityUnits: Int {
        return marketItems
            .filter { !$0.isByWeight }
            .reduce(0) { $0 + Int($1.quantity) }
    }
    
    // Soma apenas por peso
    var totalQuantityWeight: Double {
        return marketItems
            .filter { $0.isByWeight }
            .reduce(0) { $0 + $1.quantity }
    }
    
    var marketItemsForView: [MarketItem] {
        return marketItems
    }
    
    init(repository: MarketItemRepositoryProtocol = MarketItemRepository()) {
        self.repository = repository
        loadItems()
    }
    
    func loadItems() {
        marketItems = repository.loadItems()
        filteredMarketItems = marketItems
        onDataChanged?()
    }
    
    func numberOfRows() -> Int {
        return filteredMarketItems.count
    }
    
    func itemForRow(at index: Int) -> MarketItem {
        return filteredMarketItems[index]
    }
    
    func updateQuantity(itemID: UUID, quantity: Int) {
        if let index = marketItems.firstIndex(where: { $0.id == itemID }) {
            let oldItem = marketItems[index]
            let updatedItem = MarketItem(id: oldItem.id, name: oldItem.name, unitPrice: oldItem.unitPrice, quantity: Double(quantity), isByWeight: oldItem.isByWeight)
            marketItems[index] = updatedItem
            repository.saveItems(marketItems)
            applyFilter()
            onDataChanged?()
        }
    }
    
    func updateItem(_ item: MarketItem) {
        guard let index = marketItems.firstIndex(where: { $0.id == item.id }) else { return }
        marketItems[index] = item
        repository.saveItems(marketItems)
        applyFilter()
        onDataChanged?()
    }
    
    func addItem(_ item: MarketItem) {
        marketItems.insert(item, at: 0)
        repository.saveItems(marketItems)
        applyFilter()
        onDataChanged?()
    }
    
    func removeItem(at index: Int) {
        guard filteredMarketItems.indices.contains(index) else { return }
        let itemToRemove = filteredMarketItems[index]
        if let marketIndex = marketItems.firstIndex(where: { $0.id == itemToRemove.id }) {
            marketItems.remove(at: marketIndex)
            repository.saveItems(marketItems)
            applyFilter()
            onDataChanged?()
        }
    }
    
    func finalizePurchase() -> Purchase {
        return Purchase(items: marketItems)
    }
    
    func clearItems() {
        marketItems.removeAll()
        filteredMarketItems.removeAll()
        repository.saveItems([])
        onDataChanged?()
    }
    
    func search(text: String) {
        currentSearchText = text
        applyFilter()
        onDataChanged?()
    }
    
    private func normalize(_ text: String) -> String {
        return text
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func applyFilter() {
        let search = normalize(currentSearchText)
        if search.isEmpty {
            filteredMarketItems = marketItems
            return
        }
        
        filteredMarketItems = marketItems.filter { item in
            let nameMatches = normalize(item.name).contains(search)
            
            let quantityMatches: Bool
            if search.contains("qtd") {
                quantityMatches = !item.isByWeight
            } else if search.contains("kg") {
                quantityMatches = item.isByWeight
            } else {
                quantityMatches = false
            }
            
            return nameMatches || quantityMatches
        }
    }
}

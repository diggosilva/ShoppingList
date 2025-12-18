//
//  Repository.swift
//  ShoppingList
//
//  Created by Diggo Silva on 18/12/25.
//

import Foundation

protocol RepositoryProtocol: AnyObject {
    func loadItems() -> [MarketItem]
    func saveItems(_ items: [MarketItem])
}

final class Repository: RepositoryProtocol {
    
    private let userDefaults = UserDefaults.standard
    private let keyMarket = "keyMarket"
    
    func loadItems() -> [MarketItem] {
        if let data = userDefaults.data(forKey: keyMarket) {
            if let decodedItems = try? JSONDecoder().decode([MarketItem].self, from: data) {
                return decodedItems
            }
        }
        return []
    }
    
    func saveItems(_ items: [MarketItem]) {
        if let encodedItems = try? JSONEncoder().encode(items) {
            userDefaults.set(encodedItems, forKey: keyMarket)
        }
    }
}

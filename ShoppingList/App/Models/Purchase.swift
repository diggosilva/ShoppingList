//
//  Purchase.swift
//  ShoppingList
//
//  Created by Diggo Silva on 24/12/25.
//

import Foundation

struct Purchase: Codable {
    let id: UUID
    let date: Date
    let items: [MarketItem]
    
    var totalValue: Double {
        return items.reduce(0) { $0 + $1.totalValue }
    }
    
    var totalItems: Int {
        return items.count
    }
    
    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    init(items: [MarketItem]) {
        self.id = UUID()
        self.date = Date()
        self.items = items
    }
    
    init(id: UUID = UUID(), date: Date, items: [MarketItem]) {
        self.id = id
        self.date = date
        self.items = items
    }
}

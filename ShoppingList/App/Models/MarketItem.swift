//
//  MarketItem.swift
//  ShoppingList
//
//  Created by Diggo Silva on 18/12/25.
//

import Foundation

struct MarketItem: Codable {
    let id: UUID
    let name: String
    let unitPrice: Double
    let quantity: Int
    
    var totalValue: Double {
        return unitPrice * Double(quantity)
    }
    
    // Init para item NOVO
    init(name: String, unitPrice: Double, quantity: Int) {
        id = UUID()
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
    }
    
    // Init para item EXISTENTE (edição)
    init(id: UUID, name: String, unitPrice: Double, quantity: Int) {
        self.id = id
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
    }
}

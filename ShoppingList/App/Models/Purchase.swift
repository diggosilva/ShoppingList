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
    let item: [MarketItem]
    
    let totalValue: Double
    let totalItems: Int
    let totalQuantity: Int
}

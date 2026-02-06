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
    let quantity: Double
    let isByWeight: Bool

    var totalValue: Double {
        return unitPrice * quantity
    }

    // Init para item NOVO
    init(name: String, unitPrice: Double, quantity: Double, isByWeight: Bool) {
        id = UUID()
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.isByWeight = isByWeight
    }

    // Init para item EXISTENTE (edição)
    init(id: UUID, name: String, unitPrice: Double, quantity: Double, isByWeight: Bool) {
        self.id = id
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.isByWeight = isByWeight
    }
}

extension MarketItem {
    var quantityString: String {
        if isByWeight {
            return quantity.cleanDecimal + " kg"
        } else {
            return "\(Int(quantity)) un"
        }
    }
}

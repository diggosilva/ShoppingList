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
    
    var totalQuantity: Double {
        return items.reduce(0) { $0 + $1.quantity }
    }
    
    /// Retorna a quantidade total formatada separando unidades de peso
    var totalQuantityString: String {
        var parts: [String] = []
        
        // Soma itens por unidades
        let totalUnits = items.filter { !$0.isByWeight }.reduce(0) { $0 + Int($1.quantity) }
        if totalUnits > 0 {
            parts.append("\(totalUnits) unidades")
        }
        
        // Soma itens por peso
        let totalKg = items.filter { $0.isByWeight }.reduce(0) { $0 + $1.quantity }
        if totalKg > 0 {
            let formattedKg = totalKg.cleanDecimal
            parts.append("\(formattedKg) kg")
        }
        
        return parts.joined(separator: " • ")
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

// MARK: - Extensions
extension Double {
    /// Remove zeros desnecessários de casas decimais (ex: 1.0 -> 1, 1.234 -> 1.234)
    var cleanDecimal: String {
        let formatted = String(format: "%.3f", self) // até 3 casas
        var trimmed = formatted
        while trimmed.last == "0" { trimmed.removeLast() } // remove zeros à direita
        if trimmed.last == "." { trimmed.removeLast() }   // remove ponto se necessário
        return trimmed
    }
}

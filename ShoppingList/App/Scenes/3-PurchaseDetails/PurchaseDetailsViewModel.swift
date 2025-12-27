//
//  PurchaseDetailsViewModel.swift
//  ShoppingList
//
//  Created by Diggo Silva on 26/12/25.
//

import Foundation

protocol PurchaseDetailsViewModelProtocol: AnyObject {
    var totalValue: Double { get }
    var totalItems: Int { get }
    var totalQuantity: Int { get }
    
    func numberOfRows() -> Int
    func itemForRow(at index: Int) -> MarketItem
    
    func exportText() -> String
}

final class PurchaseDetailsViewModel: PurchaseDetailsViewModelProtocol {
        
    private let purchase: Purchase
    
    var totalValue: Double {
        return purchase.totalValue
    }
    
    var totalItems: Int {
        return purchase.totalItems
    }
    
    var totalQuantity: Int {
        return purchase.totalQuantity
    }
    
    init(purchase: Purchase) {
        self.purchase = purchase
    }
    
    func numberOfRows() -> Int {
        return purchase.items.count
    }
    
    func itemForRow(at index: Int) -> MarketItem {
        return purchase.items[index]
    }
    
    func exportText() -> String {
        var lines: [String] = []
        
        lines.append("*DETALHES DA COMPRA*")
        lines.append(formatDate(purchase.date))
        lines.append("")
        
        for item in purchase.items {
            let line = """
                \(item.name)
                \(formatCurrency(value: item.unitPrice)) x \(item.quantity) = *\(formatCurrency(value: item.totalValue))*
                """
            lines.append(line)
            lines.append("")
        }
        lines.append("*_TOTAL_: \(formatCurrency(value: purchase.totalValue))*")
        lines.append("_Itens_: \(purchase.totalItems)")
        lines.append("_Unidades_: \(purchase.totalQuantity)")
        
        return lines.joined(separator: "\n")
    }
}

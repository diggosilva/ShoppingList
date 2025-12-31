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

    func filterItems(with text: String)
    func currentSearchText() -> String
    func resetFilter()
    
    func exportText() -> String
}

final class PurchaseDetailsViewModel: PurchaseDetailsViewModelProtocol {
        
    private let purchase: Purchase
    private var filteredItems: [MarketItem] = []
    private var isFiltering = false
    private var searchText: String = ""
    
    var totalValue: Double { return purchase.totalValue }
    var totalItems: Int { return purchase.totalItems }
    var totalQuantity: Int { return purchase.totalQuantity }
    
    init(purchase: Purchase) {
        self.purchase = purchase
    }
    
    func numberOfRows() -> Int {
        return isFiltering ? filteredItems.count : purchase.items.count
    }
    
    func itemForRow(at index: Int) -> MarketItem {
        return isFiltering ? filteredItems[index] : purchase.items[index]
    }
    
    func filterItems(with text: String) {
        searchText = text
        
        let normalizedSearch = text.normalizedForSearch()
        
        guard !normalizedSearch.isEmpty else {
            resetFilter()
            return
        }
        
        isFiltering = true
        filteredItems = purchase.items.filter {
            $0.name.normalizedForSearch().contains(normalizedSearch) ||
            $0.unitPrice.description.lowercased().contains(normalizedSearch) ||
            $0.quantity.description.lowercased().contains(normalizedSearch)
        }
    }
    
    func currentSearchText() -> String {
        return searchText
    }
    
    func resetFilter() {
        isFiltering = false
        filteredItems = []
        searchText = ""
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

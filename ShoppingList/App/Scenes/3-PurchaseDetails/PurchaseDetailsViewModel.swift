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
}

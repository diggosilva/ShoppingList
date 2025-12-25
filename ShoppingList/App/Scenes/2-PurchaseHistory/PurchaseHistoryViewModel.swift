//
//  PurchaseHistoryViewModel.swift
//  ShoppingList
//
//  Created by Diggo Silva on 24/12/25.
//

import Foundation

protocol PurchaseHistoryViewModelProtocol: AnyObject {
    func numberOfRows() -> Int
    func purchaseForRow(at index: Int) -> Purchase
    func loadPurchases()
}

final class PurchaseHistoryViewModel: PurchaseHistoryViewModelProtocol {
    
    private var purchases: [Purchase] = []
    private let repository: PurchaseRepositoryProtocol
    
    init(repository: PurchaseRepositoryProtocol = PurchaseRepository()) {
        self.repository = repository
        loadPurchases()
    }
    
    func numberOfRows() -> Int {
        return purchases.count
    }
    
    func purchaseForRow(at index: Int) -> Purchase {
        return purchases[index]
    }
    
    func loadPurchases() {
        purchases = repository.loadPurchases().sorted(by: { $0.date > $1.date })
    }
}

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
    func monthlySpending() -> [MonthlySpend]
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
    
    func monthlySpending() -> [MonthlySpend] {
        let calendar = Calendar.current
        var spending: [DateComponents : Double] = [:]

        purchases.forEach { purchase in
            let components = calendar.dateComponents([.year, .month], from: purchase.date)
            spending[components, default: 0] += purchase.totalValue
        }

        let now = calendar.startOfMonth(for: Date())

        return (0..<6).compactMap { offset in
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: now) else {
                return nil
            }

            let components = calendar.dateComponents([.year, .month], from: monthDate)
            let total = spending[components, default: 0]

            return MonthlySpend(month: monthDate, total: total)
        }
        .sorted { $0.month < $1.month }
    }
}

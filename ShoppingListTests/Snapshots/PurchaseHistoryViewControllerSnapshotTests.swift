//
//  PurchaseHistoryViewControllerSnapshotTests.swift
//  ShoppingListTests
//
//  Created by Diggo Silva on 03/01/26.
//

import XCTest
import SnapshotTesting
@testable import ShoppingList

final class PurchaseHistoryViewControllerSnapshotTests: XCTestCase {

    func test_purchaseHistory_lightMode() {
        // GIVEN
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

        let items = [
            MarketItem(name: "Arroz", unitPrice: 10, quantity: 2),
            MarketItem(name: "Feijão", unitPrice: 8, quantity: 1),
            MarketItem(name: "Carne", unitPrice: 35, quantity: 1)
        ]

        let purchase = Purchase(date: fixedDate, items: items)
        let monthly = [MonthlySpend(month: fixedDate, total: 63)]
        
        let viewModel = MockPurchaseHistoryViewModel(purchases: [purchase], monthlyData: monthly)
        let viewController = PurchaseHistoryViewController(viewModel: viewModel)

        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

        // THEN
        assertSnapshot(
            of: viewController,
            as: .image(
                on: .iPhone13Pro,
                traits: UITraitCollection(userInterfaceStyle: .light)
            ),
            record: false // ⚠️ só na primeira vez como true
        )
    }
    
    func test_purchaseHistory_emptyState_lightMode() {
        let viewModel = MockPurchaseHistoryViewModel(purchases: [], monthlyData: [])
        let viewController = PurchaseHistoryViewController(viewModel: viewModel)
        
        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        
        assertSnapshot(
            of: viewController,
            as: .image(
                on: .iPhone13Pro,
                traits: UITraitCollection(userInterfaceStyle: .light)
            ),
            record: false // ⚠️ só na primeira vez como true
        )
    }
}

final class MockPurchaseHistoryViewModel: PurchaseHistoryViewModelProtocol {

    private let purchases: [Purchase]
    private let monthlyData: [MonthlySpend]

    init(purchases: [Purchase], monthlyData: [MonthlySpend]) {
        self.purchases = purchases
        self.monthlyData = monthlyData
    }

    func numberOfRows() -> Int {
        purchases.count
    }

    func purchaseForRow(at index: Int) -> Purchase {
        purchases[index]
    }

    func loadPurchases() {
        // não faz nada
    }

    func monthlySpending() -> [MonthlySpend] {
        monthlyData
    }
}

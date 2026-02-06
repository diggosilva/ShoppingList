//
//  PurchaseHistoryViewModelTests.swift
//  ShoppingListTests
//
//  Created by Diggo Silva on 29/12/25.
//

import XCTest
@testable import ShoppingList

final class PurchaseHistoryViewModelTests: XCTestCase {
    
    private var repository: MockPurchaseRepository!
    private var sut: PurchaseHistoryViewModel!
    
    override func setUp() {
        super.setUp()
        repository = MockPurchaseRepository()
        sut = PurchaseHistoryViewModel(repository: repository)
    }
    
    override func tearDown() {
        repository = nil
        sut = nil
        super.tearDown()
    }
    
    func test_fetchPurchases() {
        let item1 = MarketItem(name: "Leite", unitPrice: 5, quantity: 1, isByWeight: false)
        let item2 = MarketItem(name: "Pão", unitPrice: 19.90, quantity: 0.080, isByWeight: true)
        let purchase = Purchase(items: [item1, item2])
        
        repository.purchasesToLoad = [purchase]
        
        sut.loadPurchases()
        
        XCTAssertEqual(sut.purchaseForRow(at: 0).totalItems, 2)
        XCTAssertEqual(sut.numberOfRows(), 1)
    }
    
    func test_loadPurchases_sortsPurchasesByDateDescending() {
        let item = MarketItem(name: "Leite", unitPrice: 5, quantity: 1, isByWeight: false)
        
        let olderDate = Date(timeIntervalSince1970: 1000)
        let newerDate = Date(timeIntervalSince1970: 2000)
        
        let olderPurchase = Purchase(date: olderDate, items: [item])
        let newerPurchase = Purchase(date: newerDate, items: [item])
        
        // Ordem inserida errada propositalmente
        repository.purchasesToLoad = [olderPurchase, newerPurchase]
        
        sut.loadPurchases()
        
        XCTAssertEqual(sut.numberOfRows(), 2)
        XCTAssertEqual(sut.purchaseForRow(at: 0).date, newerDate)
        XCTAssertEqual(sut.purchaseForRow(at: 1).date, olderDate)
    }
    
    func test_monthlySpending_returnsSixMonths() {
        let result = sut.monthlySpending()
        
        XCTAssertEqual(result.count, 6)
    }
    
    func test_monthlySpending_aggregatesPurchasesInSameMonth() {
        let now = Date()
        
        let item1 = MarketItem.mock(unitPrice: 100)
        let item2 = MarketItem.mock(unitPrice: 50)
        
        let purchase1 = Purchase(date: now, items: [item1])
        let purchase2 = Purchase(date: now, items: [item2])
        
        repository.purchasesToLoad = [purchase1, purchase2]
        sut.loadPurchases()
        
        let result = sut.monthlySpending()
        let currentMonth = result.last
        
        XCTAssertEqual(currentMonth?.total, 150)
    }
    
    func test_monthlySpending_sumsMultipleItemsInSinglePurchase() {
        let now = Date()
        
        let item1 = MarketItem.mock(unitPrice: 10, quantity: 2)
        let item2 = MarketItem.mock(unitPrice: 15, quantity: 2)
        
        let purchase = Purchase(date: now, items: [item1, item2])
        
        repository.purchasesToLoad = [purchase]
        sut.loadPurchases()
        
        let result = sut.monthlySpending()
        let currentMonth = result.last
        
        XCTAssertEqual(currentMonth?.total, 50)
    }
    
    func test_monthlySpending_includesMonthsWithZeroSpending() {
        let now = Date()
        
        let item = MarketItem.mock(unitPrice: 200)
        
        let purchase = Purchase(date: now, items: [item])
        
        repository.purchasesToLoad = [purchase]
        sut.loadPurchases()
        
        let result = sut.monthlySpending()
        
        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result.contains { $0.total == 0 })
    }
}

extension MarketItem {
    static func mock(unitPrice: Double, quantity: Int = 1, name: String = "Item") -> MarketItem {
        return MarketItem(name: name, unitPrice: unitPrice, quantity: Double(quantity), isByWeight: false)
    }
}

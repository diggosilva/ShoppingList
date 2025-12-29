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
        let item1 = MarketItem(name: "Leite", unitPrice: 5, quantity: 1)
        let item2 = MarketItem(name: "Pão", unitPrice: 2, quantity: 1)
        let purchase = Purchase(items: [item1, item2])
        
        repository.purchasesToLoad = [purchase]
        
        sut.loadPurchases()
        
        XCTAssertEqual(sut.purchaseForRow(at: 0).totalItems, 2)
        XCTAssertEqual(sut.numberOfRows(), 1)
    }
    
    func test_loadPurchases_sortsPurchasesByDateDescending() {
        let item = MarketItem(name: "Leite", unitPrice: 5, quantity: 1)
        
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
}

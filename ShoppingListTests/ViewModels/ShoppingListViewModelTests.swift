//
//  ShoppingListTests.swift
//  ShoppingListTests
//
//  Created by Diggo Silva on 28/12/25.
//

import XCTest
@testable import ShoppingList

final class ShoppingListViewModelTests: XCTestCase {
    
    private var repository: MockMarketItemRepository!
    private var sut: ShoppingListViewModel!
    
    override func setUp() {
        super.setUp()
        repository = MockMarketItemRepository()
        sut = ShoppingListViewModel(repository: repository)
    }
    
    override func tearDown() {
        repository = nil
        sut = nil
        super.tearDown()
    }
    
    func test_AddItem_IncrementsNumberOfRows() {
        let item = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2)

        sut.addItem(item)
        
        XCTAssertEqual(sut.numberOfRows(), 1)
    }
    
    func test_TotalPurchaseValue_isCalculatedCorrectly() {
        let item1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2)
        let item2 = MarketItem(name: "Feijão", unitPrice: 5, quantity: 3)
        
        sut.addItem(item1)
        sut.addItem(item2)
        
        XCTAssertEqual(sut.totalPurchaseValue, 35)
    }
    
    func test_addItem_savesItemsInRepositoty() {
        let item = MarketItem(name: "Macarrão", unitPrice: 4, quantity: 1)
        
        sut.addItem(item)
        
        XCTAssertEqual(repository.savedItems.count, 1)
        XCTAssertEqual(repository.savedItems.first?.name, "Macarrão")
    }
    
    func test_finalizePurchase_createsPurchaseWithCorrectTotals() {
        let item = MarketItem(name: "Leite", unitPrice: 5, quantity: 12)
        
        sut.addItem(item)
        
        let purchase = sut.finalizePurchase()
        
        XCTAssertEqual(purchase.items.count, 1)
        XCTAssertEqual(purchase.totalQuantity, 12)
        XCTAssertEqual(purchase.totalValue, 60)
    }
    
    func test_updateItem_whenRenamedOrRepriced_theItemIsUpdated() {
        let item = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2)
        
        sut.addItem(item)
        
        let updatedItem = MarketItem(id: item.id, name: "Arroz Branco", unitPrice: 10, quantity: 2)
        
        sut.updateItem(updatedItem)
        
        XCTAssertEqual(sut.itemForRow(at: 0).name, "Arroz Branco")
    }
    
    func test_updateItem_whenQuantityIsUpdated_theItemIsUpdated() {
        let item = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2)
        
        sut.addItem(item)
        
        let updatedItem = MarketItem(id: item.id, name: "Arroz", unitPrice: 10, quantity: 4)
        
        sut.updateQuantity(itemID: updatedItem.id, quantity: updatedItem.quantity)
        
        XCTAssertEqual(sut.itemForRow(at: 0).quantity, 4)
    }
    
    func test_removeItem_removesTheSpecifiedItem() {
        let item1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2)
        let item2 = MarketItem(name: "Feijão", unitPrice: 5, quantity: 3)
        
        sut.addItem(item1)
        sut.addItem(item2)
        
        XCTAssertEqual(sut.numberOfRows(), 2)
        
        sut.removeItem(at: 0)
        
        XCTAssertEqual(sut.numberOfRows(), 1)
        XCTAssertEqual(sut.itemForRow(at: 0).name, "Arroz")
    }
    
    func test_removeAllItems_removesAllItems() {
        let item1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2)
        let item2 = MarketItem(name: "Feijão", unitPrice: 5, quantity: 3)
        
        sut.addItem(item1)
        sut.addItem(item2)
        
        XCTAssertEqual(sut.numberOfRows(), 2)
        
        sut.clearItems()
        
        XCTAssertEqual(sut.numberOfRows(), 0)
        XCTAssertEqual(repository.savedItems.count, 0)
    }
    
    func test_addItem_triggerOnDataChanged() {
        let expectation = XCTestExpectation(description: "onDataChanged called")
        
        sut.onDataChanged = {
            expectation.fulfill()
        }
        
        let item = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2)
        
        sut.addItem(item)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_updateItem_withIbvalidId_doesNotTriggerOnDataChanged() {
        let expectation = XCTestExpectation(description: "onDataChanged should not be called")
        expectation.isInverted = true
        
        sut.onDataChanged = {
            expectation.fulfill()
        }
        
        let invalidItem = MarketItem(id: UUID(), name: "Inexistente", unitPrice: 10, quantity: 1)
        
        sut.updateItem(invalidItem)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_clearItems_triggersOnDataChanged() {
        let expectation = XCTestExpectation(description: "onDataChanged called")

        sut.onDataChanged = {
            expectation.fulfill()
        }

        sut.clearItems()

        wait(for: [expectation], timeout: 1.0)
    }
}

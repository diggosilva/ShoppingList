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
        let item = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        
        sut.addItem(item)
        
        XCTAssertEqual(sut.numberOfRows(), 1)
    }
    
    func test_TotalPurchaseValue_isCalculatedCorrectly() {
        let item1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let item2 = MarketItem(name: "Pão", unitPrice: 19.90, quantity: 0.080, isByWeight: true)
        
        sut.addItem(item1)
        sut.addItem(item2)
        
        XCTAssertEqual(sut.totalPurchaseValue, 21.592)
    }
    
    func test_addItem_savesItemsInRepositoty() {
        let item = MarketItem(name: "Macarrão", unitPrice: 4, quantity: 1, isByWeight: false)
        
        sut.addItem(item)
        
        XCTAssertEqual(repository.savedItems.count, 1)
        XCTAssertEqual(repository.savedItems.first?.name, "Macarrão")
    }
    
    func test_finalizePurchase_createsPurchaseWithCorrectTotals() {
        let item = MarketItem(name: "Leite", unitPrice: 5, quantity: 12, isByWeight: false)
        
        sut.addItem(item)
        
        let purchase = sut.finalizePurchase()
        
        XCTAssertEqual(purchase.items.count, 1)
        XCTAssertEqual(purchase.totalQuantity, 12)
        XCTAssertEqual(purchase.totalValue, 60)
    }
    
    func test_updateItem_whenRenamedOrRepriced_theItemIsUpdated() {
        let item = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        
        sut.addItem(item)
        
        let updatedItem = MarketItem(id: item.id, name: "Arroz Branco", unitPrice: 10, quantity: 2, isByWeight: false)
        
        sut.updateItem(updatedItem)
        
        XCTAssertEqual(sut.itemForRow(at: 0).name, "Arroz Branco")
    }
    
    func test_updateItem_whenQuantityIsUpdated_theItemIsUpdated() {
        let item = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        
        sut.addItem(item)
        
        let updatedItem = MarketItem(id: item.id, name: "Arroz", unitPrice: 10, quantity: 4, isByWeight: false)
        
        sut.updateQuantity(itemID: updatedItem.id, quantity: Int(updatedItem.quantity))
        
        XCTAssertEqual(sut.itemForRow(at: 0).quantity, 4)
    }
    
    func test_removeItem_removesTheSpecifiedItem() {
        let item1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let item2 = MarketItem(name: "Feijão", unitPrice: 5, quantity: 3, isByWeight: false)
        
        sut.addItem(item1)
        sut.addItem(item2)
        
        XCTAssertEqual(sut.numberOfRows(), 2)
        
        sut.removeItem(at: 0)
        
        XCTAssertEqual(sut.numberOfRows(), 1)
        XCTAssertEqual(sut.itemForRow(at: 0).name, "Arroz")
    }
    
    func test_removeAllItems_removesAllItems() {
        let item1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let item2 = MarketItem(name: "Feijão", unitPrice: 5, quantity: 3, isByWeight: false)
        
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
        
        let item = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        
        sut.addItem(item)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_updateItem_withIbvalidId_doesNotTriggerOnDataChanged() {
        let expectation = XCTestExpectation(description: "onDataChanged should not be called")
        expectation.isInverted = true
        
        sut.onDataChanged = {
            expectation.fulfill()
        }
        
        let invalidItem = MarketItem(id: UUID(), name: "Inexistente", unitPrice: 10, quantity: 1, isByWeight: false)
        
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
    
    func test_totalQuantityUnits_sumsOnlyUnitItems() {
        let unitItem1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let unitItem2 = MarketItem(name: "Feijão", unitPrice: 5, quantity: 3, isByWeight: false)
        let weightItem = MarketItem(name: "Carne", unitPrice: 40, quantity: 1.5, isByWeight: true)
        
        sut.addItem(unitItem1)
        sut.addItem(unitItem2)
        sut.addItem(weightItem)
        
        XCTAssertEqual(sut.totalQuantityUnits, 5)
    }
    
    func test_totalQuantityWeight_sumsOnlyWeightItems() {
        let weightItem1 = MarketItem(name: "Carne", unitPrice: 40, quantity: 1.5, isByWeight: true)
        let weightItem2 = MarketItem(name: "Queijo", unitPrice: 30, quantity: 0.8, isByWeight: true)
        let unitItem = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        
        sut.addItem(weightItem1)
        sut.addItem(weightItem2)
        sut.addItem(unitItem)
        
        XCTAssertEqual(sut.totalQuantityWeight, 2.3, accuracy: 0.0001)
    }
    
    func test_marketItemsForView_returnsAllItems() {
        let item1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let item2 = MarketItem(name: "Feijão", unitPrice: 5, quantity: 3, isByWeight: false)
        
        sut.addItem(item1)
        sut.addItem(item2)
        
        let itemsForView = sut.marketItemsForView
        
        XCTAssertEqual(itemsForView.count, 2)
        XCTAssertTrue(itemsForView.contains(where: { $0.name == "Arroz" }))
        XCTAssertTrue(itemsForView.contains(where: { $0.name == "Feijão" }))
    }
    
    func test_search_filtersItemsByName() {
        let arroz = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let feijao = MarketItem(name: "Feijão", unitPrice: 5, quantity: 3, isByWeight: false)
        
        sut.addItem(arroz)
        sut.addItem(feijao)
        
        sut.search(text: "arr")
        
        XCTAssertEqual(sut.numberOfRows(), 1)
        XCTAssertEqual(sut.itemForRow(at: 0).name, "Arroz")
    }
    
    func test_search_withQtd_filtersOnlyUnitItems() {
        let unitItem = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let weightItem = MarketItem(name: "Carne", unitPrice: 40, quantity: 1.5, isByWeight: true)
        
        sut.addItem(unitItem)
        sut.addItem(weightItem)
        
        sut.search(text: "qtd")
        
        XCTAssertEqual(sut.numberOfRows(), 1)
        XCTAssertFalse(sut.itemForRow(at: 0).isByWeight)
    }
    
    func test_search_withKg_filtersOnlyWeightItems() {
        let unitItem = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let weightItem = MarketItem(name: "Carne", unitPrice: 40, quantity: 1.5, isByWeight: true)
        
        sut.addItem(unitItem)
        sut.addItem(weightItem)
        
        sut.search(text: "kg")
        
        XCTAssertEqual(sut.numberOfRows(), 1)
        XCTAssertTrue(sut.itemForRow(at: 0).isByWeight)
    }
    
    func test_search_withEmptyText_restoresAllItems() {
        let item1 = MarketItem(name: "Arroz", unitPrice: 10, quantity: 2, isByWeight: false)
        let item2 = MarketItem(name: "Carne", unitPrice: 40, quantity: 1.5, isByWeight: true)
        
        sut.addItem(item1)
        sut.addItem(item2)
        
        sut.search(text: "arroz")
        XCTAssertEqual(sut.numberOfRows(), 1)
        
        sut.search(text: "")
        XCTAssertEqual(sut.numberOfRows(), 2)
    }
}

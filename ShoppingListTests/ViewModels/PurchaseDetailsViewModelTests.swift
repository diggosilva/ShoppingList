//
//  PurchaseDetailsViewModelTests.swift
//  ShoppingListTests
//
//  Created by Diggo Silva on 29/12/25.
//

import XCTest
@testable import ShoppingList

final class PurchaseDetailsViewModelTests: XCTestCase {
    
    private var sut: PurchaseDetailsViewModel!
    
    override func setUp() {
        super.setUp()
        let items = [
            MarketItem(name: "Leite", unitPrice: 5, quantity: 2, isByWeight: false),
            MarketItem(name: "Pão", unitPrice: 19.90, quantity: 0.080, isByWeight: true)
        ]
        
        let purchase = Purchase(date: Date(timeIntervalSince1970: 1000), items: items)
        
        sut = PurchaseDetailsViewModel(purchase: purchase)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_totals_shouldReturnTheCorrectValues() {
        XCTAssertEqual(sut.totalValue, 11.592)
        XCTAssertEqual(sut.totalItems, 2)
        XCTAssertEqual(sut.totalQuantity, 2.08)
    }
    
    func test_numberOfRows_withoutFilters_shouldReturnTheCorrectValue() {
        XCTAssertEqual(sut.numberOfRows(), 2)
    }
    
    func test_itemForRow_withoutFilter_returnsCorrectItem() {
        let item = sut.itemForRow(at: 0)
        XCTAssertEqual(item.name, "Leite")
    }
    
    func test_filterItem_byName_filtersCorrectly() {
        sut.filterItems(with: "p")
        XCTAssertEqual(sut.itemForRow(at: 0).name, "Pão")
    }
    
    func test_filterItems_byQuantity_filtersCorrectly() {
        sut.filterItems(with: "2")
        XCTAssertEqual(sut.itemForRow(at: 0).name, "Leite")
    }
    
    func test_filterItems_withEmptyText_resetsFilter() {
        sut.filterItems(with: "lei")
        sut.filterItems(with: "")

        XCTAssertEqual(sut.numberOfRows(), 2)
        XCTAssertEqual(sut.currentSearchText(), "")
    }
    
    func test_resetFilter_restoresOriginalItems() {
        sut.filterItems(with: "lei")
        sut.resetFilter()
        
        XCTAssertEqual(sut.numberOfRows(), 2)
    }
    
    func test_currentSearchText_returnsLastSearch() {
        sut.filterItems(with: "pao")
        XCTAssertEqual(sut.currentSearchText(), "pao")
    }
    
    func test_exportText_containsPurchaseSummary() {
        let text = sut.exportText()
        
        XCTAssertTrue(text.contains("DETALHES DA COMPRA"))
        XCTAssertTrue(text.contains("Leite"))
        XCTAssertTrue(text.contains("Pão"))
        XCTAssertTrue(text.contains("Itens"))
        XCTAssertTrue(text.contains("Unidades"))
        XCTAssertTrue(text.contains("TOTAL"))
    }
}

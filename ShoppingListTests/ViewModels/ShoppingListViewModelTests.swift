//
//  ShoppingListTests.swift
//  ShoppingListTests
//
//  Created by Diggo Silva on 28/12/25.
//

import XCTest
@testable import ShoppingList

final class ShoppingListViewModel: XCTestCase {
    
    private var repository: MockMarketItemRepository!
    private var sut: ShoppingListViewModel!
    
    override func setUp() {
        super.setUp()
        repository = MockMarketItemRepository()
        sut = ShoppingListViewModel(repository: repository)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
}


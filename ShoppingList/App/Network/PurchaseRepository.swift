//
//  PurchaseRepository.swift
//  ShoppingList
//
//  Created by Diggo Silva on 24/12/25.
//

import Foundation

protocol PurchaseRepositoryProtocol: AnyObject {
    func loadPurchases() -> [Purchase]
    func savePurchases(_ purchases: [Purchase])
}

final class PurchaseRepository: PurchaseRepositoryProtocol {
    
    let userDefaults = UserDefaults.standard
    let keyPurchases = "keyPurchases"
    
    func loadPurchases() -> [Purchase] {
        guard let data = userDefaults.data(forKey: keyPurchases),
              let decodedPurchases = try? JSONDecoder().decode([Purchase].self, from: data)
        else { return [] }
        return decodedPurchases
    }
    
    func savePurchases(_ purchases: [Purchase]) {
        if let encodedPurchases = try? JSONEncoder().encode(purchases) {
            userDefaults.set(encodedPurchases, forKey: keyPurchases)
        }
    }
}

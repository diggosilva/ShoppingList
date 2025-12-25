//
//  PurchaseHistoryViewController.swift
//  ShoppingList
//
//  Created by Diggo Silva on 25/12/25.
//

import UIKit

class PurchaseHistoryViewController: UIViewController {
    
    private let purchaseHistoryView = PurchaseHistoryView()
    private let viewModel: PurchaseHistoryViewModelProtocol
    
    init(viewModel: PurchaseHistoryViewModelProtocol = PurchaseHistoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        view = purchaseHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureDelegatesAndDataSources()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Histórico de Compras"
    }
    
    private func configureDelegatesAndDataSources() {
        purchaseHistoryView.tableView.dataSource = self
        purchaseHistoryView.tableView.delegate = self
        purchaseHistoryView.tableView.reloadData()
    }
}

extension PurchaseHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let purchase = viewModel.purchaseForRow(at: indexPath.row)
        
        var content = cell.defaultContentConfiguration()
        content.text = "Compra em realizada em: "
        content.secondaryText = "\(formatDate(purchase.date))\n Total: \(formatCurrency(value: purchase.totalValue))"
        content.image = UIImage(systemName: "cart.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension PurchaseHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

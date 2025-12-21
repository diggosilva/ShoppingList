//
//  ShoppingListViewController.swift
//  ShoppingList
//
//  Created by Diggo Silva on 17/12/25.
//

import UIKit

class ShoppingListViewController: UIViewController {
    
    private let shoppingListView = ShoppingListView()
    private let viewModel: ShoppingListViewModelProtocol
    
    init(viewModel: ShoppingListViewModelProtocol = ShoppingListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        view = shoppingListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureDelegatesAndDataSources()
        binding()
        viewModel.loadItems()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Lista de Compras 🛒"
    }
    
    private func configureDelegatesAndDataSources() {
        shoppingListView.tableView.dataSource = self
        shoppingListView.tableView.delegate = self
    }
    
    private func binding() {
        viewModel.onDataChanged = { [weak self] in
            self?.shoppingListView.tableView.reloadData()
            self?.updateTotal()
        }
    }
    
    private func updateTotal() {
        let total = viewModel.totalValue()
        shoppingListView.totalLabel.text = "Total: \(formatCurrency(value: total))"
    }
}

extension ShoppingListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListCell.identififer, for: indexPath) as? ShoppingListCell else { return UITableViewCell() }
        let item = viewModel.itemForRow(at: indexPath.row)
        cell.configure(item: item)
        cell.onQuantityChanged = { [weak self] newQuantity in
            self?.viewModel.updateQuantity(itemID: item.id, quantity: newQuantity)
        }
        return cell
    }
}

extension ShoppingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

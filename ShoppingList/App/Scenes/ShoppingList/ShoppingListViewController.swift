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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemTapped))
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
    
    @objc private func addItemTapped() {
        let alert = UIAlertController(title: "Novo Item", message: "Informe os dados do produto", preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "Nome do Produto"
            $0.autocapitalizationType = .words
            $0.clearButtonMode = .whileEditing
        }
        
        alert.addTextField {
            $0.placeholder = "Preço unitário"
            $0.keyboardType = .decimalPad
            $0.clearButtonMode = .whileEditing
        }
        
        alert.addTextField {
            $0.placeholder = "Quantidade"
            $0.keyboardType = .numberPad
            $0.text = "1"
            $0.clearButtonMode = .whileEditing
        }
        
        let addAction = UIAlertAction(title: "Adicionar", style: .default) { [weak self] _ in
            self?.handleAddItem(alert: alert)
        }
        
        addAction.isEnabled = false
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.textFields?.forEach {
            $0.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }
        present(alert, animated: true)
    }
    
    @objc private func textDidChange(sender: UITextField) {
        guard let alert = presentedViewController as? UIAlertController,
              let textFields = alert.textFields,
              let addAction = alert.actions.first else { return }
        
        let name = textFields[0].text ?? ""
        let priceText = textFields[1].text ?? ""
        let quantityText = textFields[2].text ?? ""
        
        let price = Double(priceText.replacingOccurrences(of: ",", with: "."))
        let quantity = Int(quantityText)
        
        let isValid = !name.isEmpty && price != nil && (quantity ?? 0) > 0
        
        addAction.isEnabled = isValid
    }
    
    private func handleAddItem(alert: UIAlertController) {
        guard let fields = alert.textFields else { return }
        
        let name = fields[0].text!
        let price = Double(fields[1].text!.replacingOccurrences(of: ",", with: "."))!
        let quantity = Int(fields[2].text!)!
        
        let item = MarketItem(name: name, unitPrice: price, quantity: quantity)
        viewModel.addItem(item)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Apagar") { [weak self] _, _, completion in
            self?.viewModel.removeItem(at: indexPath.row)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

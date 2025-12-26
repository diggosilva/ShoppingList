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
}

// MARK: - TableView
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
            guard let self = self else {
                completion(false)
                return
            }
            
            self.viewModel.removeItem(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Editar") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            
            let item = self.viewModel.itemForRow(at: indexPath.row)
            self.showEditAlert(for: item, at: indexPath)
            completion(true)
        }
        
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil")
        return UISwipeActionsConfiguration(actions: [editAction])
    }
}

// MARK: - Setup
extension ShoppingListViewController {
    private func configureNavigationBar() {
        navigationItem.title = "Lista de Compras 🛒"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "clock"), style: .plain, target: self, action: #selector(openHistory)),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishPurchase)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemTapped)),
        ]
    }
    
    @objc private func openHistory() {
        let purchaseVC = PurchaseHistoryViewController()
        navigationController?.pushViewController(purchaseVC, animated: true)
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
        let total = viewModel.totalPurchaseValue
        shoppingListView.totalLabel.text = "Total: \(formatCurrency(value: total))"
        shoppingListView.itemsLabel.text = viewModel.totalItems > 1 ? "\(viewModel.totalItems) itens" : "\(viewModel.totalItems) item"
        shoppingListView.quantityLabel.text = viewModel.totalQuantity > 1 ? "\(viewModel.totalQuantity) unidades" : "\(viewModel.totalQuantity) unidade"
    }
}

// MARK: - Alerts
extension ShoppingListViewController {
    @objc private func finishPurchase() {
        let alert = UIAlertController(title: "Finalizar Compra", message: "Deseja realmente finalizar a compra?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { action in
            self.hasItemsToPurchase()
        }
        
        alert.addAction(ok)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func hasItemsToPurchase() {
        if viewModel.numberOfRows() == 0 {
            showAlertPurchaseEmpty()
        } else {
            let purchase = self.viewModel.finalizePurchase()
            let historyRepository = PurchaseRepository()
            
            var history = historyRepository.loadPurchases()
            history.append(purchase)
            historyRepository.savePurchases(history)
            
            self.viewModel.clearItems()
            self.showAlertPurchaseSaved()
        }
    }
    
    private func showAlertPurchaseEmpty() {
        let alert = UIAlertController(title: "Carrinho vazio ❌", message: "Seu carrinho está vazio. Adicione itens para finalizar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    private func showAlertPurchaseSaved() {
        let alert = UIAlertController(title: "Compra salva ✅", message: "Sua compra foi adicionada ao histórico.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func addItemTapped() {
        let alert = UIAlertController(title: "Novo Item", message: "Informe os dados do produto", preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "Nome do Produto"
            $0.autocapitalizationType = .words
        }
        
        alert.addTextField {
            $0.placeholder = "Preço unitário"
            $0.keyboardType = .decimalPad
        }
        
        alert.addTextField {
            $0.placeholder = "Quantidade"
            $0.keyboardType = .numberPad
            $0.text = "1"
        }
        
        let addAction = UIAlertAction(title: "Adicionar", style: .default) { [weak self] _ in
            self?.handleAddItem(alert: alert)
        }
        addAction.isEnabled = false
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        alert.textFields?.forEach {
            $0.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
            $0.clearButtonMode = .whileEditing
        }
        present(alert, animated: true)
    }
    
    private func showEditAlert(for item: MarketItem, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Editar Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField { $0.text = item.name; $0.autocapitalizationType = .words }
        alert.addTextField {
            $0.text = String(item.unitPrice)
            $0.keyboardType = .decimalPad
        }
        alert.addTextField {
            $0.text = String(item.quantity)
            $0.keyboardType = .numberPad
        }
        
        let saveAction = UIAlertAction(title: "Salvar", style: .default) { [weak self] _ in
            guard let self = self,
                  let updatedItem = self.makeItemFromAlert(alert, existingID: item.id)
            else { return }
            
            self.viewModel.updateItem(updatedItem)
            self.shoppingListView.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.updateTotal()
        }
        
        saveAction.isEnabled = true
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        alert.textFields?.forEach {
            $0.addTarget(self, action: #selector(self.textDidChange), for: .editingChanged)
            $0.clearButtonMode = .whileEditing
        }
        present(alert, animated: true)
    }
    
    @objc private func textDidChange(_ sender: UITextField) {
        guard let alert = presentedViewController as? UIAlertController,
              let fields = alert.textFields,
              let mainAction = alert.actions.first else { return }
        
        let name = fields[0].text ?? ""
        let price = Double(fields[1].text?.replacingOccurrences(of: ",", with: ".") ?? "")
        let quantity = Int(fields[2].text ?? "")
        
        mainAction.isEnabled = !name.isEmpty && price != nil && (quantity ?? 0) > 0
    }
    
    private func makeItemFromAlert(_ alert: UIAlertController, existingID: UUID? = nil) -> MarketItem? {
        guard let fields = alert.textFields,
              let name = fields[0].text, !name.isEmpty,
              let price = Double(fields[1].text!.replacingOccurrences(of: ",", with: ".")),
              let quantity = Int(fields[2].text!),
              quantity > 0 else { return nil }
        
        if let id = existingID {
            return MarketItem(id: id, name: name, unitPrice: price, quantity: quantity)
        } else {
            return MarketItem(name: name, unitPrice: price, quantity: quantity)
        }
    }
    
    private func handleAddItem(alert: UIAlertController) {
        guard let item = makeItemFromAlert(alert) else { return }
        viewModel.addItem(item)
    }
}

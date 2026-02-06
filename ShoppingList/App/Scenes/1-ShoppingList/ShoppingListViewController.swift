//
//  ShoppingListViewController.swift
//  ShoppingList
//
//  Created by Diggo Silva on 17/12/25.
//

import UIKit

class ShoppingListViewController: UIViewController {
    
    private let contentView = ShoppingListView()
    private let viewModel: ShoppingListViewModelProtocol
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    init(viewModel: ShoppingListViewModelProtocol = ShoppingListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() { view = contentView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureDelegatesAndDataSources()
        binding()
        viewModel.loadItems()
        enableDismissKeyboardOnTapOutsideSearch()
    }
    
    private func enableDismissKeyboardOnTapOutsideSearch() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSearchKeyboard))
        tapGesture.cancelsTouchesInView = false
        contentView.tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissSearchKeyboard() {
        searchController.searchBar.resignFirstResponder()
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
        
        searchController.searchBar.placeholder = "Buscar items..."
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc private func openHistory() {
        let purchaseVC = PurchaseHistoryViewController()
        navigationController?.pushViewController(purchaseVC, animated: true)
    }
    
    private func configureDelegatesAndDataSources() {
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
    }
    
    private func binding() {
        viewModel.onDataChanged = { [weak self] in
            self?.contentView.tableView.reloadData()
            self?.updateTotal()
        }
    }
    
    private func updateTotal() {
        let total = viewModel.totalPurchaseValue
        contentView.totalLabel.text = "Total: \(formatCurrency(value: total))"
        contentView.itemsLabel.text = viewModel.totalItems > 1 ? "\(viewModel.totalItems) itens" : "\(viewModel.totalItems) item"
        
        // Quantidade separada
        let units = viewModel.totalQuantityUnits
        let weight = viewModel.totalQuantityWeight
        
        var quantityText = ""
        if units > 0 {
            quantityText += "\(units) unidades"
        }
        if weight > 0 {
            if !quantityText.isEmpty { quantityText += ", " }
            quantityText += "\(String(format: "%.3f", weight)) Kg"
        }
        
        contentView.quantityLabel.text = quantityText
    }
}

// MARK: - Alerts
extension ShoppingListViewController {
    @objc private func finishPurchase() {
        let alert = UIAlertController(title: "Finalizar Compra", message: "Deseja realmente finalizar a compra?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { _ in
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
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlertPurchaseSaved() {
        let alert = UIAlertController(title: "Compra salva ✅", message: "Sua compra foi adicionada ao histórico.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func addItemTapped() {
        let alert = UIAlertController(title: "Novo Item", message: "Informe os dados do produto", preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "Nome do Produto"
            $0.autocapitalizationType = .words
        }
        
        alert.addTextField {
            $0.placeholder = "Preço (unitário ou kg)"
            $0.keyboardType = .decimalPad
        }
        
        alert.addTextField {
            $0.placeholder = "Quantidade / Peso"
            $0.keyboardType = .decimalPad
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
            $0.keyboardType = .decimalPad
        }
        
        let saveAction = UIAlertAction(title: "Salvar", style: .default) { [weak self] _ in
            guard let self = self,
                  let updatedItem = self.makeItemFromAlert(alert, existingID: item.id)
            else { return }
            
            self.viewModel.updateItem(updatedItem)
            self.contentView.tableView.reloadRows(at: [indexPath], with: .automatic)
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
        
        let priceText = fields[1].text?.replacingOccurrences(of: ",", with: ".") ?? ""
        let price = Double(priceText)
        
        let quantityText = fields[2].text?.replacingOccurrences(of: ",", with: ".") ?? ""
        let quantity = Double(quantityText)
        
        mainAction.isEnabled = !name.isEmpty && price != nil && (quantity ?? 0) > 0
    }
    
    private func makeItemFromAlert(_ alert: UIAlertController, existingID: UUID? = nil) -> MarketItem? {
        guard let fields = alert.textFields,
              let name = fields[0].text, !name.isEmpty else { return nil }
        
        let priceText = fields[1].text!.replacingOccurrences(of: ",", with: ".")
        let quantityText = fields[2].text!.replacingOccurrences(of: ",", with: ".")
        
        guard let price = Double(priceText),
              let quantity = Double(quantityText),
              quantity > 0 else { return nil }
        
        let isByWeight = quantity.truncatingRemainder(dividingBy: 1) != 0
        
        if let id = existingID {
            return MarketItem(id: id, name: name, unitPrice: price, quantity: quantity, isByWeight: isByWeight)
        } else {
            return MarketItem(name: name, unitPrice: price, quantity: quantity, isByWeight: isByWeight)
        }
    }
    
    private func handleAddItem(alert: UIAlertController) {
        guard let item = makeItemFromAlert(alert) else { return }
        viewModel.addItem(item)
    }
}

extension ShoppingListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        viewModel.search(text: text)
        contentView.tableView.reloadData()
    }
}

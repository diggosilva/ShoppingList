//
//  PurchaseDetailsViewController.swift
//  ShoppingList
//
//  Created by Diggo Silva on 26/12/25.
//

import UIKit

class PurchaseDetailsViewController: UIViewController {
    
    private let purchaseDetailsView = PurchaseDetailsView()
    private let viewModel: PurchaseDetailsViewModelProtocol
    
    init(viewModel: PurchaseDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        view = purchaseDetailsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchController()
        configureDataSource()
        updateTotal()
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        let hasResults = viewModel.numberOfRows() > 0
        
        guard !hasResults else {
            contentUnavailableConfiguration = nil
            return
        }
        
        var config = UIContentUnavailableConfiguration.empty()
        config.image = UIImage(systemName: "magnifyingglass")
        config.text = "Nenhum item encontrado"
        
        let searchText = viewModel.currentSearchText()
        
        if searchText.isEmpty {
            config.secondaryText = "Essa compra não possui itens."
        } else {
            config.secondaryText = "Nenhum item corresponde a \"\(searchText)\""
        }
        contentUnavailableConfiguration = config
    }
}

//MARK: TableView
extension PurchaseDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseItemCell.identifier, for: indexPath) as? PurchaseItemCell else { return UITableViewCell() }
        let item = viewModel.itemForRow(at: indexPath.row)
        let searchText = viewModel.currentSearchText()
        cell.configure(item: item, highlight: searchText)
        cell.backgroundColor = backgroundColor(for: indexPath)
        return cell
    }
    
    private func backgroundColor(for indexPath: IndexPath) -> UIColor {
        return indexPath.row.isMultiple(of: 2) ? .systemBackground : .systemCyan.withAlphaComponent(0.2)
    }
}

//MARK: Setup
extension PurchaseDetailsViewController {
    private func configureNavigationBar() {
        navigationItem.title = "Detalhes da Compra"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportPurchase))
    }
    
    @objc private func exportPurchase() {
        let alert = UIAlertController(title: "Exportar compra", message: "Escolha o formato", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "PDF", style: .default) { _ in
            self.exportAsPDF()
        })
        
        alert.addAction(UIAlertAction(title: "Texto (WhatsApp)", style: .default) { _ in
            self.exportAsText()
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func exportAsPDF() {
        let builder = PurchasePDFBuilder(viewModel: viewModel)
        let pdfData = builder.build()
        let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func exportAsText() {
        let text = viewModel.exportText()
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func configureDataSource() {
        purchaseDetailsView.tableView.dataSource = self
    }
    
    private func updateTotal() {
        purchaseDetailsView.totalLabel.text = "TOTAL: \(formatCurrency(value: viewModel.totalValue))"
        purchaseDetailsView.totalItemsLabel.text = "Itens: \(viewModel.totalItems)"
        purchaseDetailsView.totalUnitLabel.text = "Unidades: \(viewModel.totalQuantity)"
    }
}

//MARK: SearchController
extension PurchaseDetailsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        text.isEmpty ? viewModel.resetFilter() : viewModel.filterItems(with: text)
        
        purchaseDetailsView.tableView.reloadData()
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    private func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar um item..."
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

//MARK: SearchControllerDelegate
extension PurchaseDetailsViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.resetFilter()
        purchaseDetailsView.tableView.reloadData()
        setNeedsUpdateContentUnavailableConfiguration()
    }
}

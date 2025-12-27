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
        configureDataSource()
        updateTotal()
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
        cell.configure(item: item)
        cell.backgroundColor = backgroundColor(for: indexPath)
        return cell
    }
    
    private func backgroundColor(for indexPath: IndexPath) -> UIColor {
        return indexPath.row.isMultiple(of: 2) ? .systemCyan.withAlphaComponent(0.2) : .systemBackground
    }
}

//MARK: Setup
extension PurchaseDetailsViewController {
    private func configureNavigationBar() {
        navigationItem.title = "Detalhes da Compra"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportPurchase))
    }
    
    @objc private func exportPurchase() {
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

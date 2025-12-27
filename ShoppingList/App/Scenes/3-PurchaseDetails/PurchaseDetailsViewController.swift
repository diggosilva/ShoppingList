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
    
    private func configureNavigationBar() {
        navigationItem.title = "Detalhes da Compra"
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

extension PurchaseDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseItemCell.identifier, for: indexPath) as? PurchaseItemCell else { return UITableViewCell() }
        let item = viewModel.itemForRow(at: indexPath.row)
        cell.configure(item: item)
        return cell
    }
}

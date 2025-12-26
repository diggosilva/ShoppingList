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
        configureDelegatesAndDataSources()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Detalhes da Compra"
    }
    
    private func configureDelegatesAndDataSources() {
        purchaseDetailsView.tableView.dataSource = self
        purchaseDetailsView.tableView.delegate = self
        purchaseDetailsView.tableView.reloadData()
    }
}

extension PurchaseDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = viewModel.itemForRow(at: indexPath.row).name
        content.image = UIImage(systemName: "cart")
        
        cell.contentConfiguration = content
        return cell
    }
}

extension PurchaseDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

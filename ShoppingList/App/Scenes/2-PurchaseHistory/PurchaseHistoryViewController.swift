//
//  PurchaseHistoryViewController.swift
//  ShoppingList
//
//  Created by Diggo Silva on 25/12/25.
//

import SwiftUI

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
        setupChartHeader()
    }
    
    private func setupChartHeader() {
        let data = viewModel.monthlySpending()

        guard !data.isEmpty else {
            purchaseHistoryView.tableView.tableHeaderView = nil
            return
        }

        let chartView = MonthlySpendingChartView(data: data)
        let hostingController = UIHostingController(rootView: chartView)
        hostingController.view.backgroundColor = UIColor.clear

        let height: CGFloat = 180
        hostingController.view.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: height
        )
        purchaseHistoryView.tableView.tableHeaderView = hostingController.view
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseHistoryCell.identifier, for: indexPath) as? PurchaseHistoryCell else { return UITableViewCell() }
        
        let purchase = viewModel.purchaseForRow(at: indexPath.row)
        cell.configure(with: purchase)
        return cell
    }
}

extension PurchaseHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let purchase = viewModel.purchaseForRow(at: indexPath.row)
        let viewModel = PurchaseDetailsViewModel(purchase: purchase)
        let purchaseDetailsVC = PurchaseDetailsViewController(viewModel: viewModel)
        navigationController?.pushViewController(purchaseDetailsVC, animated: true)
    }
}

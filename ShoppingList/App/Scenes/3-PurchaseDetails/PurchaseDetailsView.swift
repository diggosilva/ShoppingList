//
//  PurchaseDetailsView.swift
//  ShoppingList
//
//  Created by Diggo Silva on 26/12/25.
//

import UIKit

final class PurchaseDetailsView: UIView {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(PurchaseItemCell.self, forCellReuseIdentifier: PurchaseItemCell.identifier)
        tv.allowsSelection = false
        return tv
    }()
    
    lazy var totalLabel = buildLabel(font: .preferredFont(forTextStyle: .headline))
    lazy var totalItemsLabel = buildLabel(font: .preferredFont(forTextStyle: .subheadline))
    lazy var totalUnitLabel = buildLabel(font: .preferredFont(forTextStyle: .subheadline))
    lazy var vStack = buildStack(views: [totalLabel, totalItemsLabel, totalUnitLabel])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        setHierarchy()
        setConstraints()
        configStack()
    }
    
    private func setHierarchy() {
        addSubviews(tableView, vStack)
        backgroundColor = .systemBackground
    }
    
    private func configStack() {
        vStack.isLayoutMarginsRelativeArrangement = true
        vStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        vStack.layer.cornerRadius = 8
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: vStack.topAnchor),
            
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

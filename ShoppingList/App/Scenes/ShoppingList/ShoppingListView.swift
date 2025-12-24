//
//  ShoppingListView.swift
//  ShoppingList
//
//  Created by Diggo Silva on 19/12/25.
//

import UIKit

class ShoppingListView: UIView {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ShoppingListCell.self, forCellReuseIdentifier: ShoppingListCell.identififer)
        return tv
    }()
    
    lazy var totalLabel = buildLabel(font: .systemFont(ofSize: 24, weight: .bold), text: "Total: R$ 0,00", textAlignment: .right)
    lazy var itemsLabel = buildLabel(font: .systemFont(ofSize: 14, weight: .medium), text: "0 itens", textAlignment: .left)
    lazy var quantityLabel = buildLabel(font: .systemFont(ofSize: 14, weight: .medium), text: "0 itens", textAlignment: .left)
    lazy var vStack = buildStack(views: [totalLabel, itemsLabel, quantityLabel])
    
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
        vStack.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        vStack.isLayoutMarginsRelativeArrangement = true
        vStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        vStack.layer.cornerRadius = 8
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: vStack.topAnchor, constant: -8),
            
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

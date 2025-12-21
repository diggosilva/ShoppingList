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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        setHierarchy()
        setConstraints()
    }
    
    private func setHierarchy() {
        addSubviews(tableView, totalLabel)
        backgroundColor = .systemBackground
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalLabel.topAnchor, constant: -8),
            
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            totalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            totalLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}

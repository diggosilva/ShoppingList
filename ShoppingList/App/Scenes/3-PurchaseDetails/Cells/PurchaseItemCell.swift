//
//  PurchaseItemCell.swift
//  ShoppingList
//
//  Created by Diggo Silva on 26/12/25.
//

import UIKit

final class PurchaseItemCell: UITableViewCell {
    
    static let identifier: String = "PurchaseItemCell"
    
    lazy var nameLabel = buildLabel(font: .preferredFont(forTextStyle: .headline), numberOfLines: 0)
    lazy var unitPriceLabel = buildLabel(font: .preferredFont(forTextStyle: .subheadline))
    lazy var quantityLabel = buildLabel(font: .preferredFont(forTextStyle: .subheadline))
    lazy var totalLabel = buildLabel(font: .preferredFont(forTextStyle: .subheadline))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        setHierarchy()
        setConstraints()
    }
    
    private func setHierarchy() {
        contentView.addSubviews(nameLabel, unitPriceLabel, quantityLabel, totalLabel)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            unitPriceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            unitPriceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            unitPriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            quantityLabel.centerYAnchor.constraint(equalTo: unitPriceLabel.centerYAnchor),
            quantityLabel.leadingAnchor.constraint(equalTo: unitPriceLabel.trailingAnchor, constant: 16),
            
            totalLabel.centerYAnchor.constraint(equalTo: unitPriceLabel.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(item: MarketItem) {
        nameLabel.text = item.name
        unitPriceLabel.text = "\(formatCurrency(value: item.unitPrice))"
        quantityLabel.text = "x\(item.quantity)"
        totalLabel.text = formatCurrency(value: item.totalValue)
    }
}

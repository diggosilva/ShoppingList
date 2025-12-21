//
//  ShoppingListCell.swift
//  ShoppingList
//
//  Created by Diggo Silva on 20/12/25.
//

import UIKit

final class ShoppingListCell: UITableViewCell {
    
    static let identififer = "ShoppingListCell"
    
    lazy var nameLabel = buildLabel(font: .preferredFont(forTextStyle: .headline), numberOfLines: 0)
    lazy var unitPriceLabel = buildLabel(font: .preferredFont(forTextStyle: .subheadline), textColor: .secondaryLabel)
    lazy var vStack1 = buildStack(views: [nameLabel, unitPriceLabel], spacing: 4)
    
    lazy var totalValueLabel = buildLabel(font: .systemFont(ofSize: 16, weight: .bold))
    lazy var quantityLabel = buildLabel(font: .systemFont(ofSize: 14, weight: .medium))
    lazy var quantityStepper = buildStepper(minValue: 1, maxValue: 50, target: self, action: #selector(quantitySelected))
    lazy var vStack2 = buildStack(views: [totalValueLabel, quantityLabel, quantityStepper], spacing: 8, alignment: .trailing)
    
    lazy var hStack = buildStack(views: [vStack1, vStack2], axis: .horizontal, spacing: 12, alignment: .center, distribution: .equalSpacing)
    
    var onQuantityChanged: ((Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func quantitySelected() {
        let quantity = Int(quantityStepper.value)
        quantityLabel.text = "Qtd: \(quantity)"
        onQuantityChanged?(quantity)
    }
    
    private func setupView() {
        setHierarchy()
        setConstraints()
    }
    
    private func setHierarchy() {
        contentView.addSubview(hStack)
    }
    
    private func setConstraints() {
        let padding: CGFloat = 12
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }
    
    func configure(item: MarketItem) {
        nameLabel.text = item.name
        unitPriceLabel.text = formatCurrency(value: item.unitPrice)
        totalValueLabel.text = "Total: \(formatCurrency(value: item.totalValue))"

        quantityLabel.text = "Qtd: \(item.quantity)"
        quantityStepper.value = Double(item.quantity)
    }
}

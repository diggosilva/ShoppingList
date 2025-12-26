//
//  PurchaseHistoryCell.swift
//  ShoppingList
//
//  Created by Diggo Silva on 25/12/25.
//

import UIKit

final class PurchaseHistoryCell: UITableViewCell {

    static let identifier = "PurchaseHistoryCell"

    private let titleLabel = UILabel()
    private let totalLabel = UILabel()
    private let infoLabel = UILabel()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        stack.axis = .vertical
        stack.spacing = 4

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        totalLabel.font = .systemFont(ofSize: 20, weight: .bold)
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .secondaryLabel

        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(totalLabel)
        stack.addArrangedSubview(infoLabel)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        accessoryType = .disclosureIndicator
    }

    func configure(with purchase: Purchase) {
        titleLabel.text = "Compra • \(formatDate(purchase.date))"
        totalLabel.text = formatCurrency(value: purchase.totalValue)
        infoLabel.text = "\(purchase.items.count) itens • \(purchase.totalQuantity) unidades"
    }
}

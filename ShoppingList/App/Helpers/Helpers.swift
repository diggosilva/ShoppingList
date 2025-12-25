//
//  Helpers.swift
//  ShoppingList
//
//  Created by Diggo Silva on 20/12/25.
//

import UIKit

//MARK: Methods
func formatCurrency(value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.decimalSeparator = ","
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.alwaysShowsDecimalSeparator = true
    return formatter.string(from: NSNumber(floatLiteral: value)) ?? "R$ 0,00"
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy - HH:mm:ss"
    return dateFormatter.string(from: date)
}

func buildLabel(font: UIFont, numberOfLines: Int = 1, text: String = "", textColor: UIColor = .label, textAlignment: NSTextAlignment = .natural) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = font
    label.numberOfLines = numberOfLines
    label.text = text
    label.textColor = textColor
    label.textAlignment = textAlignment
    return label
}

func buildStack(views: [UIView], axis: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: views)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = axis
    stack.spacing = spacing
    stack.alignment = alignment
    stack.distribution = distribution
    return stack
}

func buildStepper(minValue: Int, maxValue: Int, target: Any, action: Selector) -> UIStepper {
    let stepper = UIStepper()
    stepper.translatesAutoresizingMaskIntoConstraints = false
    stepper.minimumValue = 1
    stepper.maximumValue = 50
    stepper.addTarget(target, action: action, for: .valueChanged)
    return stepper
}

//MARK: Extensions
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

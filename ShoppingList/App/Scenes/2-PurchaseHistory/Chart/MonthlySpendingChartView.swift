//
//  MonthlySpendingChartView.swift
//  ShoppingList
//
//  Created by Diggo Silva on 31/12/25.
//

import SwiftUI
import Charts

struct MonthlySpendingChartView: View {

    let data: [MonthlySpend]

    var body: some View {
        Chart(data, id: \.month) { item in
            BarMark(
                x: .value("Mês", item.month, unit: .month),
                y: .value("Total", item.total)
            )
            .foregroundStyle(.tint)
            .cornerRadius(6)
            .opacity(0.85)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month(.abbreviated))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
    }
}

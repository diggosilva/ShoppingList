//
//  PurchasePDFBuilder.swift
//  ShoppingList
//
//  Created by Diggo Silva on 30/12/25.
//

import UIKit

final class PurchasePDFBuilder {
    
    private let viewModel: PurchaseDetailsViewModelProtocol
    
    // Layout
    private let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)  // A4
    private let margin: CGFloat = 40
    private let headerHeight: CGFloat = 80
    
    init(viewModel: PurchaseDetailsViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func buildPDFFile() -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let fileURL = FileManager.default.temporaryDirectory.appending(component: fileName())
        
        try? renderer.writePDF(to: fileURL) { context in
            var y: CGFloat = margin + headerHeight
            var pageNumber = 1
            
            context.beginPage()
            drawHeader(context: context, page: pageNumber)
            
            for index in 0..<viewModel.numberOfRows() {
                let item = viewModel.itemForRow(at: index)
                let blockHeight: CGFloat = 40
                
                if y + blockHeight > pageRect.height - margin {
                    pageNumber += 1
                    context.beginPage()
                    drawHeader(context: context, page: pageNumber)
                    y = margin + headerHeight
                }
                drawItem(item, y: y)
                y += blockHeight
            }
            y += 20
            drawTotals(y: y)
        }
        return fileURL
    }
    
    private func fileName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "yyyy-MM-dd 'as' HH.mm.ss"
        
        let dateString = formatter.string(from: Date())
        return "Lista de Compras \(dateString).pdf"
    }
}

// MARK: - Drawing Helpers
private extension PurchasePDFBuilder {
    
    func drawHeader(context: UIGraphicsPDFRendererContext, page: Int) {
        let titleAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.boldSystemFont(ofSize: 20)]
        let subTitleAttibutes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.darkGray]
        let footerAttibutes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.gray]
        
        "Detalhes da Compra".draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttributes)
        
        // Placeholder para subtítulo (pode colocar data futuramente)
        " ".draw(at: CGPoint(x: margin, y: margin), withAttributes: subTitleAttibutes)
        
        let pageText = "Página \(page)"
        pageText.draw(at: CGPoint(x: pageRect.width - margin - 60, y: pageRect.height - margin - 10), withAttributes: footerAttibutes)
    }
    
    func drawItem(_ item: MarketItem, y: CGFloat) {
        let nameFont = UIFont.boldSystemFont(ofSize: 14)
        let detailFont = UIFont.systemFont(ofSize: 12)
        
        item.name
            .draw(at: CGPoint(x: margin, y: y),
                  withAttributes: [.font: nameFont])
        
        // Aqui mantemos o mesmo formato: preço x quantidade = total
        let quantityText: String
        if item.isByWeight {
            quantityText = String(format: "%.3f kg", item.quantity)
        } else {
            quantityText = "\(Int(item.quantity)) un"
        }
        
        let detailText = "\(formatCurrency(value: item.unitPrice)) x \(quantityText) = \(formatCurrency(value: item.totalValue))"
        
        detailText
            .draw(at: CGPoint(x: margin + 20, y: y + 18),
                  withAttributes: [.font: detailFont])
    }
    
    func drawTotals(y: CGFloat) {
        let titleFont = UIFont.boldSystemFont(ofSize: 16)
        let valueFont = UIFont.systemFont(ofSize: 14)
        
        "Total: \(formatCurrency(value: viewModel.totalValue))"
            .draw(at: CGPoint(x: margin, y: y),
                  withAttributes: [.font: titleFont])
        
        "Itens: \(viewModel.totalItems)"
            .draw(at: CGPoint(x: margin, y: y + 24),
                  withAttributes: [.font: valueFont])
        
        // Aqui usamos a string formatada da ViewModel
        "Unidades: \(viewModel.totalQuantityString)"
            .draw(at: CGPoint(x: margin, y: y + 40),
                  withAttributes: [.font: valueFont])
    }
}

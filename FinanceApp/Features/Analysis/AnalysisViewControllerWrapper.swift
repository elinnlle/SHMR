//
//  AnalysisViewControllerWrapper.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 08.07.2025.
//

import SwiftUI
import UIKit

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    let direction: Direction

    func makeUIViewController(context: Context) -> AnalysisViewController {
        let vc = AnalysisViewController()
        vc.direction = direction
        return vc
    }

    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
        // ничего не обновляем
    }
}

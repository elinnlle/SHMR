//
//  UIApplication.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 18.07.2025.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    var bottomSafeAreaInset: CGFloat {
        keyWindow?.safeAreaInsets.bottom ?? 0
    }
}

//
//  UIStackView.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/22.
//

import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
    }
}

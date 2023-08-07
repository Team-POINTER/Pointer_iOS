//
//  UILabel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/03.
//

import UIKit

extension UILabel {
    func setLineSpacing(lineSpacing: CGFloat) {
        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        self.attributedText = attributedString
    }
}


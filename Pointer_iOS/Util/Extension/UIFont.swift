//
//  UIFont.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/13.
//

import UIKit

enum NotoSansKRFont: CaseIterable {
    case notoSansKrBlack
    case notoSansKrBold
    case notoSansKrLight
    case notoSansKrMedium
    case notoSansKrRegular
    case notoSansKrThin
    
    var fontName: String {
        switch self {
        case .notoSansKrBlack: return "NotoSansKR-Black"
        case .notoSansKrBold: return "NotoSansKR-Bold"
        case .notoSansKrLight: return "NotoSansKR-Light"
        case .notoSansKrMedium: return "NotoSansKR-Medium"
        case .notoSansKrRegular: return "NotoSansKR-Medium"
        case .notoSansKrThin: return "NotoSansKR-Thin"
        }
    }
}

extension UIFont {
    static func notoSans(font: NotoSansKRFont, size: CGFloat) -> UIFont {
        return UIFont(name: font.fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func notoSansRegular(size: CGFloat) -> UIFont {
        return UIFont(name: NotoSansKRFont.notoSansKrRegular.fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func notoSansBold(size: CGFloat) -> UIFont {
        return UIFont(name: NotoSansKRFont.notoSansKrBold.fontName, size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}

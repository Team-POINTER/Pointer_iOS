//
//  UIColor.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit

extension UIColor {
    static let pointerRed = UIColor.rgb(red: 255, green: 35, blue: 1)
    static let pointerGray = UIColor.rgb(red: 217, green: 217, blue: 217)
    static let tabBarBackground = UIColor.rgb(red: 6, green: 6, blue: 6)
    static let tabbarGray = UIColor.rgb(red: 197, green: 183, blue: 205)
    static let pointerGradientStart = UIColor.rgb(red: 57, green: 57, blue: 63)
    static let pointerGradientEnd = UIColor.rgb(red: 0, green: 0, blue: 0)
    static let pointerAlertFontColor = UIColor.rgb(red: 96, green: 95, blue: 95)
    static let inactiveGray = UIColor.rgb(red: 179, green: 183, blue: 205)
}

// RGB값을 받아서 UIColor를 리턴하는 함수
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

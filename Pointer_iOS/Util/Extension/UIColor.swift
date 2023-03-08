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
    static let tabBarBackground = UIColor.rgb(red: 18, green: 18, blue: 18)
    static let tabbarGray = UIColor.rgb(red: 197, green: 197, blue: 197)
    static let pointerGradientStart = UIColor.rgb(red: 50, green: 50, blue: 50)
    static let pointerGradientEnd = UIColor.rgb(red: 0, green: 0, blue: 0)
}

// RGB값을 받아서 UIColor를 리턴하는 함수
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

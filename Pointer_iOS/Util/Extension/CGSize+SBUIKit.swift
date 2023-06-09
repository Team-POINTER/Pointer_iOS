//
//  CGSize.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/06/09.
//

import UIKit

// Sendbird UI를 위한 CGSize Extension
extension CGSize {
    init(value: CGFloat) {
        self.init(width: value, height: value)
    }
    
    var value: CGFloat { self.width }
}

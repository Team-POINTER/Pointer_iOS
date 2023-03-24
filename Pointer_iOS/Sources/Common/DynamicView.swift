//
//  DynamicView.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/24.
//

import UIKit

// 동적으로 높이를 계산해서 반환하는 View
class DynamicView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 60) // 적절한 높이 값을 반환합니다.
    }
}

//
//  HintBackgroundView.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/09/10.
//

import UIKit

class HintBackgroundView: UIView {
    //MARK: - LifeCycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .roomCellBackgroundColor
        layer.cornerRadius = 28
        clipsToBounds = false
    }
    
    override func layoutSubviews() {
        removeGradientLayer()
        addGradientBorder(startColor: .white, endColor: .roomCellGradientEndColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    private func removeGradientLayer() {
        // 그라데이션 레이어만 찾아서 지우기
        if let existingLayers = layer.sublayers {
            for layer in existingLayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
}

//
//  UIView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit

// 뷰에 그라데이션 만들기
// 기본 값으로 
extension UIView{
    func setGradient(color1: UIColor, color2: UIColor){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
    
    
    func addNewBadgeIcon(scale: CGFloat) {
        let circleIcon: UIView = {
            let view = UIView()
            view.backgroundColor = .pointerRed
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: scale).isActive = true
            view.heightAnchor.constraint(equalToConstant: scale).isActive = true
            view.layer.cornerRadius = scale / 2
            view.clipsToBounds = true
            return view
        }()
        
        self.addSubview(circleIcon)
        
        self.topAnchor.constraint(equalTo: circleIcon.topAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: circleIcon.trailingAnchor).isActive = true
    }
    
    func addGradientBorder(startColor: UIColor, endColor: UIColor, width: CGFloat = 1.5) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = width
        
        gradientLayer.mask = maskLayer
        layer.addSublayer(gradientLayer)
    }
}

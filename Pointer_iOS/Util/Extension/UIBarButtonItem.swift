//
//  PointerRightBarButton.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/10.
//

import UIKit
import SnapKit

//MARK: - HomeView의 BarButtonItem
extension UIBarButtonItem {
    
    static func getPointerBarButton(withIconimage image: UIImage?, size: CGFloat, target: UIViewController, handler: Selector) -> UIBarButtonItem {
        
        let containerView = UIView()
        let icon = UIButton(type: .system)
        
        containerView.addSubview(icon)
        
        icon.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        icon.setImage(image, for: .normal)
        icon.contentMode = .scaleAspectFit
        icon.addTarget(target, action: handler, for: .touchUpInside)
        
        containerView.widthAnchor.constraint(equalToConstant: size).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: size).isActive = true
        containerView.backgroundColor = .darkGray
        containerView.layer.cornerRadius = size / 2
        containerView.clipsToBounds = true
        
        let iconBarButton = UIBarButtonItem(customView: containerView)
        
        return iconBarButton
    }
}

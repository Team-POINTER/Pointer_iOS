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
    
    static func getPointerBackBarButton(target: UIViewController, handler: Selector) -> UIBarButtonItem {
        let backButtonImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButtonImage, size: Device.navigationBarHeight, target: target, handler: handler)
        return backButton
    }
    
    static func getPointerBarButton(withIconimage image: UIImage?, size: CGFloat? = Device.navigationBarHeight, target: UIViewController? = nil, color: UIColor = UIColor.navBackColor, handler: Selector? = nil) -> UIBarButtonItem {
        
        let containerView = UIView()
        let icon = UIButton(type: .system)
        
        containerView.addSubview(icon)
        
        icon.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        icon.setImage(image, for: .normal)
        icon.contentMode = .scaleAspectFill
        if let target = target, let handler = handler {
            icon.addTarget(target, action: handler, for: .touchUpInside)
        }
        
        if let size = size {
            containerView.widthAnchor.constraint(equalToConstant: size).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: size).isActive = true
            containerView.layer.cornerRadius = size / 2
        }
        containerView.backgroundColor = color
        containerView.clipsToBounds = true
        
        let iconBarButton = UIBarButtonItem(customView: containerView)
        
        return iconBarButton
        
        //백버튼 두가지 색 조합 필요함
        //containerView.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
    }
}

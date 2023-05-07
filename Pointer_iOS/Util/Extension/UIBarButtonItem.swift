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
        containerView.backgroundColor = UIColor.rgb(red: 86, green: 90, blue: 102)
        containerView.layer.cornerRadius = size / 2
        containerView.clipsToBounds = true
        
        let iconBarButton = UIBarButtonItem(customView: containerView)
        
        return iconBarButton
        
        //백버튼 두가지 색 조합 필요함
        //containerView.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
    }
}

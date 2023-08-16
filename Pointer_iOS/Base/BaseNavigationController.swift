//
//  MainNavigationController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/09.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    // 네비게이션 컨트롤러 만들기
    static func templateNavigationController(_ image: UIImage?, title: String, viewController: UIViewController) -> UINavigationController {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = nil
        
        let nav = BaseNavigationController(rootViewController: viewController)
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationItem.largeTitleDisplayMode = .automatic
        
        nav.navigationBar.tintColor = .white
        
        nav.tabBarItem.image = image
        nav.tabBarItem.title = title
        
        nav.modalPresentationStyle = .overFullScreen
        
        return nav
    }
    
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

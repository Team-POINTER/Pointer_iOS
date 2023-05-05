//
//  BaseTabbarController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit

class BaseTabBarController: UITabBarController {
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarSetting()
        configureViewControllers()
    }
    
    //MARK: - Function
    private func configureViewControllers() {
        
        // 첫번째 탭
        let firstVC = HomeController()
        let nav1 = templateNavigationController(UIImage(systemName: "message.fill"), title: "메시지", viewController: firstVC)
        
        // 두번째 탭
        let secondVC = ProfileViewController()
        let nav2 = templateNavigationController(UIImage(systemName: "house"), title: "홈", viewController: secondVC)
        
        // 세번째 탭
        let thirdVC = PreferenceController()
        let nav3 = templateNavigationController(UIImage(systemName: "person.circle"), title: "프로필", viewController: thirdVC)
        
        // 탭들 Setup
        viewControllers = [nav1, nav2, nav3]
    }
    
    // 네비게이션 컨트롤러 만들기
    private func templateNavigationController(_ image: UIImage?, title: String,  viewController:UIViewController) -> UINavigationController {
        let nav = BaseNavigationController(rootViewController: viewController)
        nav.tabBarItem.image = image
        nav.tabBarItem.title = title
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = nil
        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
        nav.navigationItem.largeTitleDisplayMode = .never
        
        nav.navigationBar.tintColor = .white
        return nav
    }
    
    func tabBarSetting() {
        if #available(iOS 15.0, *){
            tabBar.tintColor = .pointerRed
            tabBar.unselectedItemTintColor = .tabbarGray
            tabBar.backgroundColor = .tabBarBackground
            tabBar.barStyle = .black
            tabBar.layer.masksToBounds = false
            tabBar.isTranslucent = false
        }
    }
}

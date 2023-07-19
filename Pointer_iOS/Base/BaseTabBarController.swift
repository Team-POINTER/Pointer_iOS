//
//  BaseTabbarController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit
import SendbirdUIKit

class BaseTabBarController: UITabBarController {
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureAuth()
    }
    
    //MARK: - Auth 상태에 따라 View 변경
    func configureAuth() {
        print("🔥ConfigureAuth")
        // 유저 토큰이 존재하면
        if TokenManager.getUserAccessToken() != nil {
            // ToDo - 액세스 토큰 유효 검사
            configureViewControllers()
        } else {
            // 로그인 뷰 띄우기
            presentAuthView()
        }
    }
    
    //MARK: - 로그인 뷰 띄우기
    private func presentAuthView() {
        // 유저 토큰이 존재하지 않다면
        DispatchQueue.main.async { [weak self] in
            let loginView = LoginViewController()
            loginView.modalPresentationStyle = .fullScreen
            self?.present(loginView, animated: true)
        }
    }
    
    //MARK: - Function
    private func configureViewControllers() {
        tabBarSetting()
        // 첫번째 탭
        let firstVC = FriendsListViewController(type: .normal)
        let nav1 = templateNavigationController(UIImage(systemName: "message.fill"), title: "메시지", viewController: firstVC)
        
        // 두번째 탭
        let secondVC = HomeController()
        let nav2 = templateNavigationController(UIImage(systemName: "house"), title: "홈", viewController: secondVC)
        
        // 세번째 탭
        let thirdVC = ProfileViewController()
        let nav3 = templateNavigationController(UIImage(systemName: "person.circle"), title: "프로필", viewController: thirdVC)
        
        // 탭들 Setup
        viewControllers = [nav1, nav2, nav3]
        selectedIndex = 1
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

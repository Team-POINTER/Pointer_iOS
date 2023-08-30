//
//  BaseTabbarController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit

class BaseTabBarController: UITabBarController {
    //MARK: - Properties
    private var hasFirstLoaded = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        configureAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if hasFirstLoaded == false {
//            configureAuth()
//            hasFirstLoaded = true
//        }
    }
    
    //MARK: - Auth 상태에 따라 View 변경
    func configureAuth() {
        print("🔥ConfigureAuth")
        // 유저 토큰이 존재하면
        if TokenManager.getUserAccessToken() != nil {
            print("🔥AccessToken = \(TokenManager.getUserAccessToken())")
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
            loginView.delegate = self
            loginView.modalPresentationStyle = .fullScreen
            self?.present(loginView, animated: true)
        }
    }
    
    //MARK: - Function
    func configureViewControllers() {
        tabBarSetting()
        // 첫번째 탭
//        let firstVC = UIViewController()
//        let nav1 = templateNavigationController(UIImage(systemName: "message.fill"), title: "메시지", viewController: firstVC)
        
        // 두번째 탭
        let secondVC = HomeController()
        let nav2 = BaseNavigationController.templateNavigationController(UIImage(systemName: "house"), title: "홈", viewController: secondVC)
        
        // 세번째 탭
        let viewModel = ProfileViewModel(userId: TokenManager.getIntUserId())
        let thirdVC = ProfileViewController(viewModel: viewModel)
        let nav3 = BaseNavigationController.templateNavigationController(UIImage(systemName: "person.circle"), title: "프로필", viewController: thirdVC)
        
        // 탭들 Setup
        viewControllers = [nav2, nav3]
//        selectedIndex = 0
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

extension BaseTabBarController: LoginViewDelegate {
    func loginSuccess() {
        configureAuth()
    }
}

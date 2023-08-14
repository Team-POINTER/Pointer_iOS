//
//  AppCoordinator.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/13.
//

import UIKit

class AppCoordinator {
    //MARK: - Properties
    let tabBarController: BaseTabBarController
    let authManager = AuthManager()
    
    //MARK: - Lifecycle
    init(_ tabBarController: BaseTabBarController) {
        self.tabBarController = tabBarController
    }
    
    //MARK: - Methods
    func start() {
        let launchScreen = LaunchScreenController()
        launchScreen.modalPresentationStyle = .overFullScreen
        launchScreen.modalTransitionStyle = .crossDissolve
        
        tabBarController.present(launchScreen, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.configureAuthGoToMain(launchScreen: launchScreen)
        }
    }
    
    // Auth 인증 및 메인뷰로
    func configureAuthGoToMain(launchScreen: LaunchScreenController? = nil) {
        // 시작하면 configureAuth
        print(#function)
        authManager.configureAuth { [weak self] isSuccessed in
            // 런치스크린이 있다면 dismiss
            if let launchScreen = launchScreen {
                launchScreen.dismiss(animated: true)
            }
            
            // Auth 정보가 있다면 메인으로, 없다면 로그인 뷰로
            guard let self = self else { return }
            if isSuccessed {
                self.tabBarController.configureViewControllers()
            } else {
                let loginView = LoginViewController()
                loginView.delegate = self
                loginView.modalPresentationStyle = .overFullScreen
                self.tabBarController.present(loginView, animated: true)
            }
        }
    }
    
    func logout() {
        // 유저 토큰들 다 지우기
        print(#function)
        TokenManager.resetUserToken()
        DispatchQueue.main.async { [weak self] in
            guard let tabBar = self?.tabBarController,
                  let views = tabBar.viewControllers else { return }
            views.forEach { view in
                view.removeFromParent()
            }
        }
        start()
    }
}

// LoginViewDelegate - 회원가입 완료 이후
extension AppCoordinator: LoginViewDelegate {
    func loginSuccess() {
        print(#function)
        self.configureAuthGoToMain()
    }
}

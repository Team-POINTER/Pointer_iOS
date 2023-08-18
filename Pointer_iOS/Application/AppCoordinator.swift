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
    let pushManager = RemotePushManager()
    
    // 푸시로 앱을 실행시킨 경우 데이터가 들어옴
    var userInfoByPush: [AnyHashable: Any]?
    
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
        tabBarController.viewControllers = []
        print(#function)
        authManager.configureAuth { [weak self] isSuccessed in
            // 런치스크린이 있다면 dismiss
            if let launchScreen = launchScreen {
                
                launchScreen.dismiss(animated: true)
            }
            
            // Auth 정보가 있다면 메인으로, 없다면 로그인 뷰로
            guard let self = self else { return }
            
            if isSuccessed {
                // 푸시 등록
                self.pushManager.registerRemotePushToken()
                
                // 뷰 생성
                self.tabBarController.configureViewControllers()
                
                // 들어온 푸시 데이터가 있다면?
                if let pushData = self.userInfoByPush {
                    self.userInfoByPush = nil
                    self.configurePushNotification(userInfo: pushData)
                }
                
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
        TokenManager.resetUserToken()
        DispatchQueue.main.async { [weak self] in
            guard let tabBar = self?.tabBarController,
                  let views = tabBar.viewControllers else { return }
            views.forEach { view in
                view.removeFromParent()
            }
            tabBar.viewControllers = []
        }
        configureAuthGoToMain()
    }
    
    // 실행중에 푸시 알림을 탭 했을 경우
    func configurePushNotification(userInfo: [AnyHashable: Any]) {
        // 미리 들어온 푸시 데이터가 있으면 return
        if userInfoByPush != nil {
            return
        }
        
//        guard let pushType = PushReceiver(rawValue: 0),
//              let nextViewController = pushType.getNextViewController(id: nil) else { return }
        
        // 일단 알림 뷰 로 가자..
        let notiVc = BaseNavigationController.templateNavigationController(nil, title: "알림", viewController: NotificationViewController())
        self.tabBarController.presentWithNavigationPushStyle(notiVc)
    }
}

// LoginViewDelegate - 회원가입 완료 이후
extension AppCoordinator: LoginViewDelegate {
    func loginSuccess() {
        print(#function)
        self.configureAuthGoToMain()
    }
}

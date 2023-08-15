//
//  AppDelegate.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth
import SendbirdUIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        KakaoSDK.initSDK(appKey: Secret.kakaoNativeKey)
        
        // 1. 푸시 권한 요청
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print(granted)
        }
        // 2. device 토큰 획득
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        TokenManager.saveUserAPNSToken(token: tokenString)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
          return AuthController.handleOpenUrl(url: url)
        }
       return false
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 실행중에도 알림을 수신하도록 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        completionHandler([.banner, .badge, .sound])
    }
    
    // 푸시 알림을 탭 했을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        configureNotification(userInfo: userInfo)
    }
    
    private func configureNotification(userInfo: [AnyHashable: Any]) {
        print("🔔푸시: \(userInfo)")
        sceneDelegate?.appCoordinator?.configurePushNotification(userInfo: userInfo)
    }
}

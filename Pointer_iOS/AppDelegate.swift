//
//  AppDelegate.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit
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
        
        SendbirdUI.initialize(applicationId: Secret.sendbird_App) {
            // Do something to display the start of the SendbirdUIKit initialization.
        } migrationHandler: {
            // Do something to display the progress of the DB migration.
        } completionHandler: { error in
            // Do something to display the completion of the SendbirdChat initialization.
        }
        
        // set current user
        SBUGlobals.currentUser = SBUUser(userId: "userA")
    
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
          return AuthController.handleOpenUrl(url: url)
        }
       return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


//
//  AuthManager.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/13.
//

import Foundation

class AuthManager {
    
    func configureAuth(completion: @escaping (Bool) -> Void) {
        if TokenManager.getUserAccessToken() == nil {
            // 로그인 뷰
            completion(false)
        } else {
            // 정상 진행
            completion(true)
            print("🔥AccessToken = \(TokenManager.getUserAccessToken())")
        }
    }
}

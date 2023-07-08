//
//  AuthManager.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/07/08.
//

import Foundation

struct AuthManager {
    
    // 디바이스에 저장한 토큰을 받아오기
    static func getUserToken() -> String? {
        return UserDefaults.standard.string(forKey: "token")
    }
    
    // 디바이스에 토큰 저장하기
    static func saveUserToken(token: String) {
        UserDefaults.standard.set(token, forKey: "token")
    }
}

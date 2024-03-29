//
//  AuthManager.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/07/08.
//

import Foundation

struct TokenManager {
    
    // 디바이스에 저장한 토큰을 받아오기
    static func getUserAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "accessToken")
    }
    
    static func getUserRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: "refreshToken")
    }
    
    static func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: "userId")
    }
    
    // 디바이스에 토큰 저장하기
    static func saveUserAccessToken(accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
    }
    
    static func saveUserRefreshToken(refreshToken: String) {
        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
    }
    
    static func saveUserId(userId: String) {
        UserDefaults.standard.set(userId, forKey: "userId")
    }
    
    static func saveIntUserId(userId: Int) {
        UserDefaults.standard.set("\(userId)", forKey: "userId")
    }
    
    static func resetUserToken() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "userId")
    }
    
    static func getIntUserId() -> Int {
        if let id = TokenManager.getUserId() {
            return Int(id) ?? 0
        } else {
            return 0
        }
    }
    
    // 푸시토큰
    static func saveUserAPNSToken(token: String) {
        UserDefaults.standard.set(token, forKey: "APNSToken")
    }
    
    static func getUserAPNSToken() -> String? {
        return UserDefaults.standard.string(forKey: "APNSToken")
    }
}

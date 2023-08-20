//
//  ProfileModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/07/27.
//

import UIKit

// MARK: - Welcome
struct ProfileModel: Codable {
    let status: Int
    let code: String
    let message: String
    var results: ProfileResults?
}

// MARK: - Results
struct ProfileResults: Codable {
    let userId: Int
    let id: String
    var userName: String
    let point: Int
    let relationship: Int?
    let imageUrls: ProfileImageUrls
}

// MARK: - ImageUrls
struct ProfileImageUrls: Codable {
    let profileImageUrl: String
    let backgroundImageUrl: String
}

//MARK: - Friends Response
struct FriendsResponseModel: Codable {
    let status: Int
    let code: String
    let message: String
    let friendInfoList: [FriendsModel]
    let name: String
    let total: Int
    let currentPage: Int
}

// MARK: - UserList
struct FriendsModel: Codable {
    let friendId: Int
    let id: String
    let friendName: String
    let file: String?
    let relationship: Int
    let status: Int?
}

//MARK: - 중복확인 결과
enum UserIdValidationResult {
    
}

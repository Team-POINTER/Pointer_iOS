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
    let results: ProfileResults?
}

// MARK: - Results
struct ProfileResults: Codable {
    let userId: Int
    let id: String
    let userName: String
    let point: Int
    let relationship: Int?
    let imageUrls: ProfileImageUrls
}

// MARK: - ImageUrls
struct ProfileImageUrls: Codable {
    let profileImageUrl: String
    let backgroundImageUrl: String
}

enum Relationship: Int {
    case block = 0
    case friendRequested = 1
    case friendRequestReceived = 2
    case friend = 3
    case friendRejected = 4
    
    // 버튼 배경색
    var backgroundColor: UIColor {
        return .pointerRed
    }
    
    var tintColor: UIColor {
        return .white
    }
    
    // attribute Title
    var attributedTitle: NSAttributedString {
        switch self {
        case .block:
            return getButtonTitle(title: "차단 해제")
        case .friendRequested:
            return getButtonTitle(title: "요청 취소")
        case .friendRequestReceived:
            return getButtonTitle(title: "요청 수락")
        case .friend:
            return getButtonTitle(title: "친구 ✓")
        case .friendRejected:
            return getButtonTitle(title: "친구 신청")
        }
    }
    
    // 버튼 Attributed Title
    func getButtonTitle(title: String) -> NSAttributedString {
        let string = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.notoSans(font: .notoSansKrMedium, size: 13)])
        return string
    }
}

//MARK: - Friends Response
struct FriendsResponseModel: Codable {
    let status: Int
    let code: String
    let message: String
    let friendsLists: [FriendsModel]
    let total: Int
}

// MARK: - UserList
struct FriendsModel: Codable {
    let userId: Int
    let id: String
    let userName: String
    let file: String
}

//MARK: - 중복확인 결과
enum UserIdValidationResult {
    
}

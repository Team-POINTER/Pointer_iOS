//
//  FriendRelationship.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/12.
//

import UIKit

enum Relationship: Int {
    case block = 0
    case friendRequested = 1
    case friendRequestReceived = 2
    case friend = 3
    case friendRejected = 4
    case none
    
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
        case .friendRejected, .none:
            return getButtonTitle(title: "친구 신청")
        }
    }
    
    // 네트워크 요청 라우터
    var router: FriendRouter {
        switch self {
        case .block: return .cancelBlockFriend
        case .friendRequested: return .cancelRequestFriend
        case .friendRequestReceived: return .acceptFreindRequest
        case .friend: return .breakFreind
        case .friendRejected, .none: return .requestFriend
        }
    }
    
    // 버튼 Attributed Title
    func getButtonTitle(title: String) -> NSAttributedString {
        let string = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.notoSans(font: .notoSansKrMedium, size: 13)])
        return string
    }
}

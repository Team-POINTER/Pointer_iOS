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
    case friendRequestReceived = 2 // 기본: 수락
    case friend = 3
    case friendRejected = 4
    case none = 5
    case `self` = 6
    case requestRejectConfig = 88
    
    // 버튼 배경색
    var backgroundColor: UIColor {
        switch self {
        case .friendRequestReceived, .block, .none, .friendRejected:
            return .pointerRed
        case .friend, .requestRejectConfig, .friendRequested, .`self`:
            return .navBackColor
        }
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
        case .requestRejectConfig:
            return getButtonTitle(title: "거절")
        case .`self`:
            return getButtonTitle(title: "나")
        }
    }
    
    var smallAttributedTitle: NSAttributedString {
        switch self {
        case .block:
            return getButtonTitle(title: "차단 해제", size: 11)
        case .friendRequested:
            return getButtonTitle(title: "요청 취소", size: 11)
        case .friendRequestReceived:
            return getButtonTitle(title: "요청 수락", size: 11)
        case .friend:
            return getButtonTitle(title: "친구 ✓", size: 11)
        case .friendRejected, .none:
            return getButtonTitle(title: "친구 신청", size: 11)
        case .requestRejectConfig:
            return getButtonTitle(title: "거절", size: 11)
        case .`self`:
            return getButtonTitle(title: "나", size: 11)
        }
    }
    
    // alert title
    var alertTitle: String {
        switch self {
        case .block: return "차단 해제"
        case .friendRequested: return "요청 취소"
        case .friendRequestReceived: return "요청 수락"
        case .friend: return "친구 해제"
        case .friendRejected, .none: return "친구 요청"
        case .requestRejectConfig: return "요청 거절"
        case .`self`: return ""
        }
    }
    
    // alert title
    var alertActionTitle: String {
        switch self {
        case .block: return "해제"
        case .friendRequested: return "확인"
        case .friendRequestReceived: return "수락"
        case .friend: return "해제"
        case .friendRejected, .none: return "요청"
        case .requestRejectConfig: return "거절"
        case .`self`: return ""
        }
    }
    
    // alert 메시지
    func getAlertMessage(targetName: String?, targetId: String?) -> String {
        
        let targetName = targetName ?? ""
        let targetId = targetId ?? ""
        
        switch self {
        case .block: return "\(targetName)(\(targetId))님의 차단을 해제하시겠어요??"
        case .friendRequested: return "친구 요청을\n취소하시겠어요?"
        case .friendRequestReceived: return "\(targetName)(\(targetId))님의 친구 요청을\n수락하시겠어요?"
        case .friend: return "\(targetName)(\(targetId))님과\n친구를 해제하시겠어요?"
        case .friendRejected, .none: return "\(targetName)(\(targetId))님에게 친구를 요청하시겠어요?"
        case .requestRejectConfig: return "\(targetName)(\(targetId))님의 요청을 거절하시겠어요?"
        case .`self`: return ""
        }
    }
    
    // 네트워크 요청 라우터
    var router: FriendRouter? {
        switch self {
        case .block: return .cancelBlockFriend
        case .friendRequested: return .cancelRequestFriend
        case .friendRequestReceived: return .acceptFreindRequest
        case .friend: return .breakFreind
        case .friendRejected, .none: return .requestFriend
        case .requestRejectConfig: return .rejectFriendRequest
        case .`self`: return nil
        }
    }
    
    // 버튼 Attributed Title
    func getButtonTitle(title: String, size: Int = 13) -> NSAttributedString {
        let string = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.notoSans(font: .notoSansKrMedium, size: CGFloat(size))])
        return string
    }
}

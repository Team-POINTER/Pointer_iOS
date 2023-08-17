//
//  PushReceiver.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/16.
//

import UIKit

enum PushType: String {
    case chat = "CHAT"
    case poke = "POKE"
    case friendRequest = "FRIEND_REQUEST"
    case friendAccept = "FRIEND_ACCEPT"
    case question = "QUESTION"
    case event = "EVENT"
    case none
    
    func generateTitle(targetUser: String? = nil) -> String {
        switch self {
        case .chat:
            return "채팅이 왔어요"
        case .poke:
            return "새로운 질문이 등록되었어요"
        case .friendRequest:
            if let user = targetUser {
                return "\(user)로부터 친구 요청이 왔어요"
            } else {
                return "친구요청이 왔어요"
            }
        case .friendAccept:
            if let user = targetUser {
                return "\(user)와 친구가 되었어요"
            } else {
                return "친구가 되었어요"
            }
        case .question:
            return "질문이 왔어요"
        case .event:
            return "이벤트가 있어요"
        case .none:
            return ""
        }
    }
}

extension PushType {
    func getNextViewController(id: Int? = nil) -> UIViewController? {
        switch self {
        case .poke, .question:
            guard let roomId = id else { return nil }
            let viewModel = RoomViewModel(roomId: roomId)
            let roomVc = RoomViewController(viewModel: viewModel)
            return roomVc
        case .friendRequest, .friendAccept:
            return UIViewController()
        default:
            return nil
        }
    }
}

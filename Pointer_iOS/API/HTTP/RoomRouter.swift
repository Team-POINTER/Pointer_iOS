//
//  RoomRouter.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/07/08.
//

import Foundation
import Alamofire

enum RoomRouter {
    case createRoom // 룸 생성
    case exitRoom(_ roomId: Int) // 룸 나가기
    case inviteMemeber // 룸 초대
    case friendsListToAttend // 초대 가능한 친구 목록
    case roomMembers(_ roomId: Int) // 룸 내부 멤버 조회
    case modifyRoomTitle // 룸 이름 변경
    case getSingleRoom(_ roomId: Int) // 룸(하나) 조회
    case getRoomList // 룸 리스트 조회
    case avaliableInviteFriendList(_ roomId: Int) // 초대 가능한 친구 조회
}

extension RoomRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .createRoom:
            return "/room/create"
        case .exitRoom(let roomId):
            return "/room/\(roomId)/exit"
        case .inviteMemeber:
            return "/room/invite/members"
        case .friendsListToAttend:
            return "/room/paging/friend/invitation?userId=1&roomId=8&currentPage=0&pageSize=2&kwd="
        case .roomMembers(let roomId):
            return "/room/get/\(roomId)/members"
        case .modifyRoomTitle:
            return "/room/verify/room-name"
        case .getSingleRoom(let roomId):
            return "/room/\(roomId)"
        case .getRoomList:
            return "/room?kwd="
        case .avaliableInviteFriendList(let roomId):
            return "/room/\(roomId)/friends"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createRoom:
            return .post
        case .exitRoom(_):
            return .get
        case .inviteMemeber:
            return .post
        case .friendsListToAttend:
            return .get
        case .roomMembers(_):
            return .get
        case .modifyRoomTitle:
            return .patch
        case .getSingleRoom:
            return .get
        case .getRoomList:
            return .get
        case .avaliableInviteFriendList:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        let token = TokenManager.getUserAccessToken() ?? ""
        return ["Content-Type": "application/json", "Authorization": "Bearer \(token)"]
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var successCode: String {
        switch self {
        case .getRoomList:
            return "J0010"
        default:
            return ""
        }
    }
    
    func body() throws -> Data? {
        return nil
    }
}

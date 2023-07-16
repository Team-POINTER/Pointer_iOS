//
//  UserRouter.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/07/16.
//

import Foundation
import Alamofire

enum UserRouter {
    /// 유저를 검색합니다.
    case searchUser
    /// 친구 리스트를 조회합니다.
    case friendsInfoList
    /// 친구를 요청합니다.
    case requestFriend
    /// 친구 요청을 취소합니다.
    case cancelFriendRequest
    /// 친구 요청을 수락합니다.
    case acceptFriend
    /// 친구 관계를 끊습니다.
    case cancelFriend
    /// 친구 요청을 거절합니다.
    case rejectFriendRequest
    /// 친구를 차단합니다.
    case blockFriend
    /// 차단 친구 목록을 조회합니다.
    case getBlockFriends
}

extension UserRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .searchUser:
            return "/search"
        case .friendsInfoList:
            return "/friend"
        case .requestFriend:
            return "/friend/request"
        case .cancelFriendRequest:
            return "/friend/request"
        case .acceptFriend:
            return "/friend"
        case .cancelFriend:
            return "/friend/cancel"
        case .rejectFriendRequest:
            return "/friend/refuse"
        case .blockFriend:
            return "/friend/block"
        case .getBlockFriends:
            return "/friend/block"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchUser:
            return .get
        case .friendsInfoList:
            return .get
        case .requestFriend:
            return .post
        case .cancelFriendRequest:
            return .put
        case .acceptFriend:
            return .post
        case .cancelFriend:
            return .post
        case .rejectFriendRequest:
            return .delete
        case .blockFriend:
            return .post
        case .getBlockFriends:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type" : "application/json"]
    }
    
    var parameters: Parameters? {
        let parameters: [String: Any] = [
            "userId": 4
        ]
        return parameters
    }
    
    func body() throws -> Data? {
        return nil
    }
}

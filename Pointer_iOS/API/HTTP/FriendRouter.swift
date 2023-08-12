//
//  FriendRouter.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/12.
//

import Foundation
import Alamofire

enum FriendRouter {
    /// 친구 요청
    case requestFriend
    /// 친구 요청 취소
    case cancelRequestFriend
    /// 친구 수락
    case acceptFreindRequest
    /// 친구 취소(관계 삭제)
    case breakFreind
    /// 친구 거절
    case rejectFriendRequest
    /// 친구 차단
    case blockFriend
    /// 친구 차단 해제
    case cancelBlockFriend
}

extension FriendRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .requestFriend:
            return "/friend/request"
        case .cancelRequestFriend:
            return "/friend/request"
        case .acceptFreindRequest:
            return "/friend/accept"
        case .breakFreind:
            return "/friend"
        case .rejectFriendRequest:
            return "/friend/refuse"
        case .blockFriend:
            return "/friend/block"
        case .cancelBlockFriend:
            return "/friend/block"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .requestFriend:
            return .post
        case .cancelRequestFriend:
            return .put
        case .acceptFreindRequest:
            return .post
        case .breakFreind:
            return .put
        case .rejectFriendRequest:
            return .post
        case .blockFriend:
            return .post
        case .cancelBlockFriend:
            return .put
        }
    }
    
    var headers: HTTPHeaders? {
        guard let accessToken = TokenManager.getUserAccessToken() else { return HTTPHeaders() }
        return ["Content-Type" : "application/json",
                "Authorization" : "Bearer \(accessToken)"]
    }
    
    var successCode: String {
        switch self {
        case .requestFriend:
            return "J000"
        case .cancelRequestFriend:
            return "J010"
        case .acceptFreindRequest:
            return "J002"
        case .breakFreind:
            return "J004"
        case .rejectFriendRequest:
            return "J005"
        case .blockFriend:
            return "J008"
        case .cancelBlockFriend:
            return "J012"
        }
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    func body() throws -> Data? {
        return nil
    }
    
    func getTargetParam(targetId: Int) -> Parameters {
        return ["memberId": String(targetId)]
    }
}

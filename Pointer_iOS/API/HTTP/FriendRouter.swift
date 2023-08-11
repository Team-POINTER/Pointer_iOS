//
//  FriendRouter.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/09.
//

import Foundation
import Alamofire

enum FriendRouter {
    case friendRequest // 친구 요청
    case friendRequestCancel // 친구 요청 취소
    case friendAccept // 친구 수락
    case friendDelete // 친구 삭제
    case friendRefuse // 친구 거절
    case friendBlock // 친구 차단
    case friendBlockCancel // 친구 차단 취소
    case userSearch // 유저 검색
    case friendSearch // 친구 검색
    case blockedFriendSearch // 차단된 친구 검색
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
        case .friendRequest:
            return "/friend/request"
        case .friendRequestCancel:
            return "/friend/request"
        case .friendAccept:
            return "/friend/accept"
        case .friendDelete:
            return "/friend"
        case .friendRefuse:
            return "/friend/refuse"
        case .friendBlock:
            return "/friend/block"
        case .friendBlockCancel:
            return "/friend/block"
        case .userSearch:
            return "/search"
        case .friendSearch:
            return "/friend/search"
        case .blockedFriendSearch:
            return "/friend/block/search"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .friendRequest:
            return .post
        case .friendRequestCancel:
            return .put
        case .friendAccept:
            return .post
        case .friendDelete:
            return .put
        case .friendRefuse:
            return .post
        case .friendBlock:
            return .post
        case .friendBlockCancel:
            return .put
        case .userSearch:
            return .post
        case .friendSearch:
            return .post
        case .blockedFriendSearch:
            return .post
        }
    }

    var headers: HTTPHeaders? {
        guard let accessToken = TokenManager.getUserAccessToken() else { return HTTPHeaders() }
        return ["Content-Type" : "application/json",
                "Authorization" : "Bearer \(accessToken)"]
    }

    var parameters: Parameters? {
        return nil
    }

    func body() throws -> Data? {
        return nil
    }
}

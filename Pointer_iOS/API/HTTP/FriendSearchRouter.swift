//
//  FriendRouter.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/09.
//

import Foundation
import Alamofire

enum FriendSearchRouter {
    case searchUser(keyword: String, lastPage: Int) // 유저 검색
    case searchfriend // 친구 검색
    case searchBlockedFriend // 차단된 친구 검색
}

extension FriendSearchRouter: HttpRouter {

    var url: String {
        return baseUrlString + path
    }

    var baseUrlString: String {
        return Secret.baseURL
    }

    var path: String {
        switch self {
        case .searchUser(let keyword, let lastPage):
            return "/user/search?keyword=\(keyword)&lastPage=\(lastPage)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        case .searchfriend:
            return "/friend/search"
        case .searchBlockedFriend:
            return "/friend/block/search"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .searchUser:
            return .get
        case .searchfriend:
            return .get
        case .searchBlockedFriend:
            return .get
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

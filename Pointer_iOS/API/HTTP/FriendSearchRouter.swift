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
    case searchBlockedFriend(keyword: String, lastPage: Int) // 차단된 친구 검색
}

extension FriendSearchRouter: HttpRouter {

    var url: String {
        return (baseUrlString + path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    var baseUrlString: String {
        return Secret.baseURL
    }

    var path: String {
        switch self {
        case .searchUser(let keyword, let lastPage):
            return "/user/search?keyword=\(keyword)&lastPage=\(lastPage)"
        case .searchfriend:
            return "/friend/search"
        case .searchBlockedFriend(let keyword, let lastPage):
            return "/friend/block/search?keyword=\(keyword)&lastPage=\(lastPage)"
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
    
    var successCode: String? {
        switch self {
        case .searchBlockedFriend:
            return "J014"
        default:
            return nil
        }
    }
}

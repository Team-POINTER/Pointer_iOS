//
//  ProfileRouter.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/07/27.
//

import Foundation
import Alamofire

enum ProfileRouter {
    case selfProfile // 자기자신 프로필
    case userProfile(_ userID: Int) // 유저 프로필
    case updateName // 유저 이름 업데이트
    case updateUserId // 유저 아이디 업데이트
    case getPoints
}

extension ProfileRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .selfProfile:
            return "/users/info"
        case .userProfile(let userId):
            return "/users/\(userId)/info"
        case .updateName:
            return "users/update/name"
        case .updateUserId:
            return "users/update/id"
        case .getPoints:
            return "users/get/points"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .selfProfile:
            return .get
        case .userProfile( _):
            return .get
        case .updateName:
            return .patch
        case .updateUserId:
            return .patch
        case .getPoints:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        guard let accessToken = TokenManager.getUserAccessToken() else { return HTTPHeaders() }
        return ["Content-Type" : "application/json",
                "Authorization" : "Bearer \(accessToken)"]
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

//
//  LoginHttpRouter.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/06/24.
//

import Foundation
import Alamofire

enum AuthRouter {
    case login
    case appleLogin
    case agree(_ accessToken: String)
    case checkId(_ accessToken: String)
    case saveId(_ accessToken: String)
    case reissue(_ refreshToken: String)
    case validate
    case resign
}

extension AuthRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .agree:
            return "/user/agree"
        case .checkId:
            return "/user/checkId"
        case .saveId:
            return "/user/id"
        case .reissue:
            return "/user/reissue"
        case .appleLogin:
            return "/auth/login/apple"
        case .validate:
            return "/user/check"
        case .resign:
            return "/user/resign"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .agree:
            return .post
        case .checkId:
            return .post
        case .saveId:
            return .post
        case .reissue:
            return .post
        case .appleLogin:
            return .post
        case .validate:
            return .get
        case .resign:
            return .delete
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .login, .appleLogin:
            return ["Content-Type" : "application/json"]
        case .agree(let accessToken):
            return ["Content-Type" : "application/json",
                    "Authorization" : "Bearer \(accessToken)"]
        case .checkId(let accessToken):
            return ["Content-Type" : "application/json",
                    "Authorization" : "Bearer \(accessToken)"]
        case .saveId(let accessToken):
            return ["Content-Type" : "application/json",
                    "Authorization" : "Bearer \(accessToken)"]
        case .reissue(let refreshToken):
            return ["Content-Type" : "application/json",
                    "Authorization" : "Bearer \(refreshToken)"]
        case .validate, .resign:
            return ["Content-Type" : "application/json",
                    "Authorization" : "Bearer \(TokenManager.getUserAccessToken() ?? "")"]
        }
        
    }
    
    var successCode: String? {
        switch self {
        case .resign:
            return "A007"
        default:
            return nil
        }
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    func body() throws -> Data? {
        return nil
    }
    
}

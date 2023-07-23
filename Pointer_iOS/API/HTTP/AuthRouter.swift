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
    case agree(_ accessToken: String)
    case checkId(_ accessToken: String)
    case saveId(_ accessToken: String)
    case reissue(_ refreshToken: String)
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
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .login:
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
        }
        
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    func body() throws -> Data? {
        return nil
    }
    
}

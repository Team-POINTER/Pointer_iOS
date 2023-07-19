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
    case checkId(_ accessToken: String)
    case saveId(_ accessToken: String)
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
        case .checkId:
            return "/auth/checkId"
        case .saveId:
            return "/auth/id"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .checkId:
            return .post
        case .saveId:
            return .post
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .login:
            return ["Content-Type" : "application/json"]
        case .checkId(let accessToken):
            return ["Content-Type" : "application/json",
                    "Authorization" : "Bearer \(accessToken)"]
        case .saveId(let accessToken):
            return ["Content-Type" : "application/json",
                    "Authorization" : "Bearer \(accessToken)"]
        }
        
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    func body() throws -> Data? {
        return nil
    }
    
}

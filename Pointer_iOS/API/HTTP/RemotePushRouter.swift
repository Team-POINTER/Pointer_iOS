//
//  RemotePushRouter.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/15.
//

import Foundation
import Alamofire

enum RemotePushRouter {
    /// 푸시 등록
    case registerPush
}

extension RemotePushRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .registerPush:
            return "/alarm/kakao"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .registerPush:
            return .post
        }
    }
    
    var headers: HTTPHeaders? {
        guard let accessToken = TokenManager.getUserAccessToken() else { return HTTPHeaders() }
        return ["Content-Type" : "application/json",
                "Authorization" : "Bearer \(accessToken)"]
    }
    
    var successCode: String {
        switch self {
        case .registerPush:
            return "A200"
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


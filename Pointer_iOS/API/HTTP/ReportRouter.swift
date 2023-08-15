//
//  ReportRouter.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/14.
//

import Foundation
import Alamofire


enum ReportRouter {
    case report // 유저 검색
    case userReport // 친구 검색
    
}

extension ReportRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
    
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .report:
            return "/report/create/"
        case .userReport:
            return "/user-report/create/"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .report:
            return .post
        case .userReport:
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

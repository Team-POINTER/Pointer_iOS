//
//  PointRouter.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/20.
//

import Foundation
import Alamofire


enum PointRouter {
    case checkPoint // 포인트 사용 문구 요청
    case usePoint(_ point: Int) // 포인트 차감
    
}

extension PointRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
    
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .checkPoint:
            return "/point"
        case .usePoint(let point):
            return "/point/\(point)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkPoint:
            return .get
        case .usePoint:
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

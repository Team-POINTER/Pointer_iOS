//
//  VoteRouter.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/14.
//

import Foundation
import Alamofire

enum VoteRouter {
    case vote // 투표하기
    case searchVotedResult(_ userId: Int ,_ questionId: Int) // 지목화면 결과 조회
    case showHint(_ userId: Int ,_ questionId: Int) // 힌트 보기
    case searchNotVotedResult(_ questionId: Int) // 지목하지 않은 사람 조회

}

extension VoteRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .vote:
            return "/votes"
        case .searchVotedResult(let userId, let questionId):
            return "/votes/\(userId)/\(questionId)"
        case .showHint(let userId, let questionId):
            return "/votes/hint/\(userId)/\(questionId)"
        case .searchNotVotedResult(let questionId):
            return "/votes/not-noted/\(questionId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .vote:
            return .post
        case .searchVotedResult:
            return .get
        case .showHint:
            return .get
        case .searchNotVotedResult:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type" : "application/json"]
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

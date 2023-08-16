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
    case votedResult(_ questionId: Int) // 지목화면 결과 조회
    case showHint(_ questionId: Int) // 힌트 보기
    case searchNotVotedResult(_ questionId: Int) // 지목하지 않은 사람 조회
    case deleteHint

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
        case .votedResult(let questionId):
            return "/votes/\(questionId)"
        case .showHint(let questionId):
            return "/votes/hint/\(questionId)"
        case .searchNotVotedResult(let questionId):
            return "/votes/not-noted/\(questionId)"
        case .deleteHint:
            return "/votes/delete/hint"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .vote:
            return .post
        case .votedResult:
            return .get
        case .showHint:
            return .get
        case .searchNotVotedResult:
            return .get
        case .deleteHint:
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

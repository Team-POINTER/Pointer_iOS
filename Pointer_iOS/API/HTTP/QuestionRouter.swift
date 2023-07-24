//
//  QuestionRouter.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/14.
//

import Foundation
import Alamofire

enum QuestionRouter {
    case createQuestion // 질문 생성
    case currentSearchQuestion(_ userId: Int ,_ roomId: Int) // 현재 질문 조회
    case totalSearchQuestion(_ userId: Int ,_ roomId: Int) // 전체 질문 조회
    case modifyQuestion(_ userId: Int ,_ questionId: Int) // 질문 수정
    case deleteQuestion(_ userId: Int ,_ questionId: Int) // 질문 삭제
}

extension QuestionRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .createQuestion:
            return "/questions"
        case .currentSearchQuestion(let userId, let roomId):
            return "/questions/current/\(userId)/\(roomId)"
        case .totalSearchQuestion(let userId, let roomId):
            return "/questions/\(userId)/\(roomId)"
        case .modifyQuestion(let userId, let questionId):
            return "/questions/\(userId)/\(questionId)"
        case .deleteQuestion(let userId, let roomId):
            return "/questions/\(userId)/\(roomId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createQuestion:
            return .post
        case .currentSearchQuestion:
            return .get
        case .totalSearchQuestion:
            return .get
        case .modifyQuestion:
            return .patch
        case .deleteQuestion:
            return .delete
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

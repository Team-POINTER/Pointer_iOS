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
    case currentSearchQuestion(_ roomId: Int) // 현재 질문 조회
    case totalSearchQuestion(_ roomId: Int) // 전체 질문 조회
    case modifyQuestion(_ questionId: Int) // 질문 수정
    case deleteQuestion(_ questionId: Int) // 질문 삭제
    case checkCreatableQuestion(_ roomId: Int) // 질문 생성 여부 확인
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
        case .currentSearchQuestion(let roomId):
            return "/questions/current/\(roomId)"
        case .totalSearchQuestion(let roomId):
            return "/questions/\(roomId)"
        case .modifyQuestion(let questionId):
            return "/questions/\(questionId)"
        case .deleteQuestion(let roomId):
            return "/questions/\(roomId)"
        case .checkCreatableQuestion(let roomId):
            return "/questions/check/\(roomId)"
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
        case .checkCreatableQuestion:
            return .get
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

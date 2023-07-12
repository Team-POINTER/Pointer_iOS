//
//  LoginDataManger.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/26.
//

import Foundation
import Alamofire

enum LoginResultType: String, CaseIterable {
    case success = "A000"
    case existedUser = "A001"
    case doubleCheck = "C004"
    case duplicatedId = "A002"
    case saveId = "C003"
    case haveToCheckId = "C005"
    case notFoundId = "C001"
    case unknownedError
    
    var message: String {
        switch self {
        case .success: return "회원가입 완료"
        case .existedUser: return "존재하는 유저"
        case .unknownedError: return "알 수 없는 에러"
        case .doubleCheck: return "아이디 사용 가능"
        case .duplicatedId: return "중복된 아이디"
        case .saveId: return "ID 저장 성공"
        case .haveToCheckId: return "ID 중복 확인 실패"
        case .notFoundId: return "회원 정보 없음"
        }
    }
}

struct AuthNetworkManager {
    
    static let shared = AuthNetworkManager()
    
    let Headers : HTTPHeaders = ["Content-Type" : "application/json"]
    
    func posts(_ parameter: AuthInputModel,_ completion: @escaping (AuthResultModel, LoginResultType) -> Void){
        print("Login URL = \(AuthRouter.login.url)")
        
        AF.request(AuthRouter.login.url, method: AuthRouter.login.method, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthResultModel.self) { response in
            switch response.result {
                // 성공인 경우
            case .success(let result):
                print("소셜 로그인 데이터 전송 성공 - \(result)")
                // rawValue로 resultType 생성
                let loginResultType = LoginResultType(rawValue: result.code) ?? .unknownedError
                // completion 전송
                completion(result, loginResultType)
                // 실패인 경우
            case .failure(let error):
                print("소셜 로그인 데이터 전송 실패")
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
    func idCheckPost(_ parameter: AuthIdInputModel,_ completion: @escaping (AuthIdResultModel, LoginResultType) -> Void) {
        
        print("중복 확인 버튼 함수 시작")
        AF.request(AuthRouter.checkId.url, method: AuthRouter.checkId.method, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthIdResultModel.self) { response in
            switch response.result {
            case .success(let result):
                print(result)
                // rawValue로 resultType 생성
                let loginResultType = LoginResultType(rawValue: result.code) ?? .unknownedError
                // 핸들러로 전송
                completion(result, loginResultType)
            case .failure(let error):
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
    func idSavePost(_ parameter: AuthIdInputModel,_ completion: @escaping (AuthIdResultModel, LoginResultType) -> Void) {
        print("확인 버튼 함수 시작")
        
        AF.request(AuthRouter.saveId.url, method: AuthRouter.saveId.method, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthIdResultModel.self) { response in
            switch response.result {
            case .success(let result):
                // rawValue로 resultType 생성
                let loginResultType = LoginResultType(rawValue: result.code) ?? .unknownedError
                completion(result, loginResultType)
            case .failure(let error):
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
}


//MARK: - 로그인 시
struct AuthInputModel: Encodable {
    let accessToken: String
}

struct AuthIdInputModel: Encodable {
    let userId: Int
    let id: String
}

struct AuthResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let userId: Int
}

struct AuthIdResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let userId: Int?
}

// 이후에
struct PointerToken: Decodable {
    let accessToken: String
    let refreshToken: String
}


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
    case dataBaseError
    
    var message: String {
        switch self {
        case .success: return "회원가입 완료"
        case .existedUser: return "존재하는 유저"
        case .dataBaseError: return "데이터 베이스 에러"
        case .doubleCheck: return "아이디 사용 가능"
        case .duplicatedId: return "중복된 아이디"
        case .saveId: return "ID 저장 성공"
        case .haveToCheckId: return "ID 중복 확인 실패"
        case .notFoundId: return "회원 정보 없음"
        }
    }
}
                            

struct LoginDataManager {
    
    static let shared = LoginDataManager()
    
    let Headers : HTTPHeaders = ["Content-Type" : "application/json"]
    
    func posts(_ parameter: AuthInputModel,_ completion: @escaping (AuthResultModel, LoginResultType) -> Void){
        print("Login URL = \(Secret.loginURL)")
        
        AF.request(Secret.loginURL, method: .post, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthResultModel.self) { response in
            switch response.result {
            case .success(let result):
                print("카카오 데이터 전송 성공")
                print(result)
                switch(result.code){
                case "A000":
                    completion(result, LoginResultType.success)
                    return
                case "A001":
                    completion(result, LoginResultType.existedUser)
                    return
                default:
                    print("데이터베이스 오류")
                    return
                }
            case .failure(let error):
                print("카카오 데이터 전송 실패")
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
    func idCheckPost(_ parameter: AuthIdInputModel,_ completion: @escaping (AuthIdResultModel, LoginResultType) -> Void) {
        
        print("중복 확인 버튼 함수 시작")
        AF.request(Secret.checkIdURL, method: .post, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthIdResultModel.self) { response in
            switch response.result {
            case .success(let result):
                print(result)
                switch(result.code){
                case "C004":
                    completion(result, LoginResultType.doubleCheck)
                    return
                case "A002":
                    completion(result, LoginResultType.duplicatedId)
                    return
                case "C001":
                    completion(result, LoginResultType.notFoundId)
                    return
                default:
                    print("데이터베이스 오류")
                    return
                }
            case .failure(let error):
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
    func idSavePost(_ parameter: AuthIdInputModel,_ completion: @escaping (AuthIdResultModel, LoginResultType) -> Void) {
        print("확인 버튼 함수 시작")
        
        AF.request(Secret.saveIdURL, method: .post, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthIdResultModel.self) { response in
            switch response.result {
            case .success(let result):
                print(result)
                switch(result.code){
                case "C003":
                    completion(result, LoginResultType.saveId)
                    return
                case "C005":
                    completion(result, LoginResultType.haveToCheckId)
                    return
                case "C001":
                    completion(result, LoginResultType.notFoundId)
                    return
                default:
                    print("데이터베이스 오류")
                    return
                }
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


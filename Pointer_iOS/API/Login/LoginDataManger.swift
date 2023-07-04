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
    case dataBaseError
    
    var message: String {
        switch self {
        case .success: return "회원가입 완료"
        case .existedUser: return "존재하는 유저"
        case .dataBaseError: return "데이터 베이스 에러"
        }
    }
}
                            

class LoginDataManager {
    
    static var Headers : HTTPHeaders = ["Content-Type" : "application/json"]
    
    static func posts(_ parameter: AuthInputModel,_ completion: @escaping (AuthResultModel, LoginResultType) -> Void){
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
}

struct AuthInputModel: Encodable {
    let accessToken: String
}

struct AuthResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let userId: Int
}

// 이후에
struct PointerToken: Decodable {
    let accessToken: String
    let refreshToken: String
}

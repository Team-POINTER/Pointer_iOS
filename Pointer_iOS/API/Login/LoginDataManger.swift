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
    
    static func posts(_ parameter: KakaoInput,_ completion: @escaping (KakaoInput, LoginResultType) -> Void){
        AF.request(Secret.loginURL, method: .post, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: KakaoModel.self) { response in
            switch response.result {
            case .success(let result):
                print("카카오 데이터 전송 성공")
                print(result)
                switch(result.code){
                case "A000":
                    completion(parameter, LoginResultType.success)
                    return
                case "A001":
                    completion(parameter, LoginResultType.existedUser)
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

struct KakaoInput: Encodable {
    var accessToken: String
}

struct KakaoModel: Decodable {
    var status: Int
    var code: String
    var message: String
    var token: String
}

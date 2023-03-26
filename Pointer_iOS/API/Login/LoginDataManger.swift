//
//  LoginDataManger.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/26.
//

import Foundation
import Alamofire

class LoginDataManager {
    static var Headers : HTTPHeaders = ["Content-Type" : "application/json"]
    

    static func posts(_ parameter: KakaoInput,_ completion: @escaping (KakaoInput) -> Void){
        AF.request("\(Secret.baseURL)", method: .post, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers).validate(statusCode: 200..<500).responseDecodable(of: KakaoModel.self) { response in
            switch response.result {
            case .success(let result):
                print("카카오 데이터 전송 성공")
                print(result)
                switch(result.status){
                case 200:
                    completion(parameter)
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
    var nickname: String
    var accessToken: String
}

struct KakaoModel: Decodable {
    var status : Int
    var message : String
    var code : String?
    var token : String?
}

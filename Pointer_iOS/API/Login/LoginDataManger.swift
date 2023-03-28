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
    
    static func posts(_ parameter: KakaoInput,_ completion: @escaping (KakaoInput, String) -> Void){
        AF.request(Secret.loginURL, method: .post, parameters: parameter, encoder: JSONParameterEncoder.default, headers: Headers).validate(statusCode: 200..<500).responseDecodable(of: KakaoModel.self) { response in
            switch response.result {
            case .success(let result):
                print("카카오 데이터 전송 성공")
                print(result)
                switch(result.code){
                case "A000":
                    completion(parameter, "회원가입 완료")
                    // 서비스 이용동의 뷰(TermsViewController)로 화면 전환[X]
                    return
                case "A001":
                    completion(parameter, "존재하는 회원")
                    // 홈으로 화면 전환[X]
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

//
//  RemotePushManager.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/15.
//

import Foundation
import Alamofire

class RemotePushManager {
    func registerRemotePushToken() {
        // 라우터
        let router = RemotePushRouter.registerPush
        
        // 파라미터 설정
        var param = [String: String]()
        param["deviceId"] = Device.uuid
        param["pushType"] = "apns"
        param["pushToken"] = TokenManager.getUserAPNSToken()
        // 디버그 모드인 경우
        #if DEBUG
        param["apnsEnv"] = "sandbox"
        #else
        // 릴리즈 모드인 경우
        param["apnsEnv"] = "production"
        #endif
        
        // 네트워크 request
        AF.request(router.url, method: router.method, parameters: param, encoder: JSONParameterEncoder.default, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: RemotePushResponse.self) { response in
                switch response.result {
                case .success(let result):
                    if result.code == router.successCode {
                        print("🔔 푸시 등록 성공 - \(result)")
                    } else {
                        print("🔔❌ 푸시 등록 성공 - \(result)")
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
}

struct RemotePushResponse: Decodable {
    let code: String
    let message: String
}

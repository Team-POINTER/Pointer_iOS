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
    
    func getRemotePushInfo(completion: @escaping (RemotePushInfoResult?) -> Void) {
        let router = RemotePushRouter.getPushEnableStatus
        // 네트워크 request
        AF.request(router.url, method: router.method, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: RemotePushInfoResponse.self) { response in
                switch response.result {
                case .success(let result):
                    if result.code == router.successCode {
                        completion(result.result)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
    }
    
    // 푸시 토글
    func requestTogglePushStatus(status: Bool, router: RemotePushRouter, completion: @escaping (Bool) -> Void) {
        AF.request(router.url, method: router.method, parameters: router.getStatusParam(status), encoding: JSONEncoding.default, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointerDefaultResponse.self) { response in
                switch response.result {
                case .success(let result):
                    print(result)
                    if result.code == router.successCode {
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
    }
    
    // 알림 리스트 호출
    func requestRoomNotiDetailList(completion: @escaping (NotiDetailRoomResponse?) -> Void) {
        let router = RemotePushRouter.getRoomPushList(lastPage: 0)
        AF.request(router.url, method: router.method, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: NotiDetailRoomResponse.self) { response in
                switch response.result {
                case .success(let result):
                    print(result)
                    if result.code == router.successCode {
                        completion(result)
                    } else { completion(nil) }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
    }
    
    // 친구 알림 리스트 호출
    func requestFriendNotiDetailList(completion: @escaping (NotiDetailFriendResponse?) -> Void) {
        let router = RemotePushRouter.getFriendPushList(lastPage: 0)
        AF.request(router.url, method: router.method, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: NotiDetailFriendResponse.self) { response in
                switch response.result {
                case .success(let result):
                    print(result)
                    if result.code == router.successCode {
                        completion(result)
                    } else { completion(nil) }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
    }
    
    // 새로운 알림 갯수 조회
    func requestNewAlarmCount(completion: @escaping (Int?) -> Void) {
        
        struct NewNotiCountResponse: Decodable {
            let code: String
            let message: String
            let result: NewNotiCount
        }

        struct NewNotiCount: Decodable {
            let newAlarmCnt: Int
        }

        
        let router = RemotePushRouter.getNewNotiCount
        AF.request(router.url, method: router.method, headers: router.headers)
            .responseDecodable(of: NewNotiCountResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    if data.code == router.successCode {
                        completion(data.result.newAlarmCnt)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
    }
    
    // 콕 찌르기
    func kokPushRequest(questionId: Int, completion: @escaping (Bool) -> Void) {
        let router = RemotePushRouter.kokPush(questionId: questionId)
        AF.request(router.url, method: router.method, headers: router.headers)
            .responseDecodable(of: PointerDefaultResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    if data.code == router.successCode {
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
    }
}

struct RemotePushResponse: Decodable {
    let code: String
    let message: String
}

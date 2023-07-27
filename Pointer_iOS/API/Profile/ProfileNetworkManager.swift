//
//  ProfileNetworkManager.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/07/27.
//

import Foundation
import Alamofire

class ProfileNetworkManager {
    
    func getMyProfile(completion: @escaping (ProfileModel?) -> Void) {
        let router = ProfileRouter.selfProfile
        
        AF.request(router.url, method: router.method, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: ProfileModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(result)
                // 실패인 경우
                case .failure(let error):
                    print("프로필 조회 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(nil)
                }
            }
    }
    
    func getUserProfile(userId: Int, completion: @escaping (ProfileModel?) -> Void) {
        let router = ProfileRouter.userProfile(userId)
        
        AF.request(router.url, method: router.method, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: ProfileModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(result)
                // 실패인 경우
                case .failure(let error):
                    print("프로필 조회 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(nil)
                }
            }
    }
}

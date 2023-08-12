//
//  FriendNetworkManager.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/12.
//

import Foundation
import Alamofire

class FriendNetworkManager {
    func requestFriendAction(_ targetUserId: Int, router: FriendRouter, completion: @escaping (Bool) -> Void) {
        AF.request(router.url, method: router.method, parameters: router.getTargetParam(targetId: targetUserId), encoding: JSONEncoding.default, headers: router.headers)
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

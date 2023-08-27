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
    
    // 친구 차단 요청
    func requestBlockFriend(targetId: Int, completion: @escaping (Bool) -> Void) {
        let router = FriendRouter.blockFriend
        let param = ["memberId": targetId]
        AF.request(router.url, method: router.method, parameters: param, encoding: JSONEncoding.default, headers: router.headers)
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
    
    // 차단 친구 조회
    func requestBlockedFriendsList(keyword: String?, lastPage: Int, completion: @escaping ([FriendsModel]?) -> Void) {
        
        let router = FriendSearchRouter.searchBlockedFriend(keyword: keyword ?? "", lastPage: lastPage)
        AF.request(router.url, method: router.method, headers: router.headers)
            .responseDecodable(of: BlockedFriendResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    if data.code == router.successCode {
                        completion(data.friendInfoList)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
    }
}

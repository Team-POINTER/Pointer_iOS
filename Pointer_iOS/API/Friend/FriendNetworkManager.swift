//
//  FriendNetworkManager.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/10.
//

import Foundation
import Alamofire

enum FriendRelation: Int, CaseIterable {
    case friendRequest // 친구 요청
    case friendRequestCancel // 친구 요청 취소
    case friendAccept // 친구 수락
    case friendDelete // 친구 삭제
    case friendRefuse // 친구 거절
    case friendBlock // 친구 차단
    case friendBlockCancel // 친구 차단 취소
}

class FriendNetworkManager {
    
//MARK: - shared
    static let shared = FriendNetworkManager()
    let friendRouter = FriendRouter.self
    
//MARK: - Function
    // 유저 검색
    func searchUserListRequest(_ parameter: SearchUserRequestModel, _ completion: @escaping (SearchUserResultModel?, Error?) -> Void) {
        let router = friendRouter.userSearch
        
        AF.request(router.url, method: router.method, parameters: parameter, encoder: JSONParameterEncoder.default, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: SearchUserResultModel.self) { respose in
                switch respose.result {
                case .success(let result):
                    completion(result, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    // 친구 관계 설정 통합
    func changeFriendRelationRequest(relation: FriendRelation, memberId: Int, _ completion: @escaping (PointerResultModel?, Error?) -> Void) {
        var router = friendRouter.friendRequest
        
        switch relation {
        case .friendRequest:
            router = friendRouter.friendRequest
        case .friendRequestCancel:
            router = friendRouter.friendRequestCancel
        case .friendAccept:
            router = friendRouter.friendAccept
        case .friendDelete:
            router = friendRouter.friendDelete
        case .friendRefuse:
            router = friendRouter.friendRefuse
        case .friendBlock:
            router = friendRouter.friendBlock
        case .friendBlockCancel:
            router = friendRouter.friendBlockCancel
        }
        
        let param = ["memberId": memberId]
        
        AF.request(router.url, method: router.method, parameters: param, encoder: JSONParameterEncoder.default, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointerResultModel.self) { respose in
                switch respose.result {
                case .success(let result):
                    completion(result, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
}


//MARK: - #1-6 유저 검색
struct SearchUserRequestModel: Encodable {
    let keyword: String
    let lastPage: Int
}

struct SearchUserResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let userList: [SearchUserListModel]
    let total: Int
    let currentPage: Int
}

struct SearchUserListModel: Decodable {
    let userId: Int
    let id: String
    let userName: String
    let file: String?
}


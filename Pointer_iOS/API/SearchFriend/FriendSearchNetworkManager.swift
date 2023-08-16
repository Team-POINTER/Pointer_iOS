//
//  FriendSearchNetworkManager.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/10.
//

import Foundation
import Alamofire

class FriendSearchNetworkManager {
    
//MARK: - shared
    static let shared = FriendSearchNetworkManager()
    let friendSeachRouter = FriendSearchRouter.self
    
//MARK: - Function
    // 유저 검색
    func searchUserListRequest(_ parameter: SearchUserRequestModel, _ completion: @escaping (SearchUserResultModel?, Error?) -> Void) {
        let router = friendSeachRouter.searchUser
        
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
    
}


//MARK: - #1-6 유저 검색
struct SearchUserRequestModel: Encodable {
    let keyword: String
    let lastPage: Int
}

struct SearchUserResultModel: Decodable {
    let status: Int
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


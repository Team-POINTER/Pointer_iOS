//
//  HomeNetworkManager.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/12.
//

import Foundation
import Alamofire
import RxSwift

class HomeNetworkManager {
    
    private lazy var httpService = PointerHttpService()
    static let shared: HomeNetworkManager = HomeNetworkManager()
    
    let Headers : HTTPHeaders = ["Content-Type" : "application/json"]
    
    
    
}

extension HomeNetworkManager: HomeAPI {
    
    func createRoom() -> RxSwift.Single<CreateRoomResultModel> {
        return Single.create { [httpService] (single) -> Disposable in
            do {
                try AuthRouter.login
                    .request(usingHttpService: httpService)
                    .responseJSON { (result) in
                        guard let data = result.data else { return }
                        
                        do {
                            let createRoomResult = try JSONDecoder().decode(CreateRoomResultModel.self, from: data)
                            print(createRoomResult)
                            single(.success(createRoomResult))
                        } catch {
                            print("createRoom Error: \(error)")
                        }
                    }
            } catch { }
            
            
            return Disposables.create()
        }
    }
}


//MARK: - 룸 생성 Input
struct CreateRoomInputModel: Encodable {
    let roomNm: String
    let userId: Int
}

//MARK: - 룸 생성 Output
struct CreateRoomResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let data: CreateRoomData?
}

struct CreateRoomData: Decodable {
    let accessToken: String?
    let refreshToken: String?
    let detailResponse: CreateRoomDetailResponse?
}

struct CreateRoomDetailResponse: Decodable {
    let roomId: Int?
    let roomNm: String?
    let memberNum: Int?
    let votingNum: Int?
    let roomMembers: [CreateRoomMember]?
}

struct CreateRoomMember: Decodable {
    let id: String?
    let name: String?
}

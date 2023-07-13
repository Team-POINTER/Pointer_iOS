//
//  HomeNetworkManager.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/12.
//

import Foundation
import Alamofire
import RxSwift

protocol HomeNetworkProtocol {
    func createRoomRequest(_ parameter: CreateRoomInputModel) -> Observable<CreateRoomResultModel>
}


class HomeNetworkManager: HomeNetworkProtocol {

    
//MARK: - shared
    static let shared = HomeNetworkManager()
    let router = RoomRouter.self
    
    
//MARK: - Observable 변환
    func createRoomRequest(_ parameter: CreateRoomInputModel) -> Observable<CreateRoomResultModel> {
        return Observable.create { (observer) -> Disposable in
            self.createRoomRequest(parameter) { error, createRoomResultModel in
                if let error = error {
                    observer.onError(error)
                }
                
                if let model = createRoomResultModel {
                    observer.onNext(model)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
//MARK: - Function
    private func createRoomRequest(_ parameter: CreateRoomInputModel,_ completion: @escaping (Error?, CreateRoomResultModel?) -> Void){
        
        AF.request(router.createRoom.url, method: router.createRoom.method, parameters: parameter, encoder: JSONParameterEncoder.default, headers: router.createRoom.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: CreateRoomResultModel.self) { response in
            switch response.result {
                // 성공인 경우
            case .success(let result):
                print("룸 생성 데이터 전송 성공 - \(result)")
                // completion 전송
                completion(nil, result)
                // 실패인 경우
            case .failure(let error):
                print("룸 생성 데이터 전송 실패 - \(error.localizedDescription)")
                // completion 전송
                completion(error, nil)
            }
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

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
    
//MARK: - shared
    static let shared = HomeNetworkManager()
    let router = RoomRouter.self
    
    
//MARK: - Observable 변환
    /// Observable.create 뭔가 공통 함수로 뺼 수 있을듯
    func requestRoomList() -> Observable<[PointerRoomModel]> {
        return Observable.create { (observer) -> Disposable in
            self.requestRoomList() { models, error in
                if let error = error {
                    observer.onError(error)
                }
                
                if let models = models {
                    observer.onNext(models)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
//MARK: - Function
    // 룸 리스트
    func requestRoomList(_ completion: @escaping ([PointerRoomModel]?, Error?) -> Void) {
        let router = RoomRouter.getRoomList
        
        AF.request(router.url, method: router.method, parameters: nil, encoding: JSONEncoding.default, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointerHomeModel.self) { response in
            switch response.result {
                // 성공인 경우
            case .success(let result):
                // completion 전송
                completion(result.data.roomList, nil)
                // 실패인 경우
            case .failure(let error):
                // completion 전송
                completion(nil, error)
            }
        }
    }
    
    // 룸 이름 변경
    func requestRoomNameChange(input: RoomNameChangeInput, completion: @escaping (PointerDefaultResponse) -> Void) {
        let router = RoomRouter.modifyRoomTitle
        
        AF.request(router.url, method: router.method, parameters: input, encoder: JSONParameterEncoder.default, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointerDefaultResponse.self) { respose in
                switch respose.result {
                case .success(let result):
                    completion(result)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    // 룸 생성
    func requestCreateRoom(roomName: String, completion: @escaping (_ roomId: Int?) -> Void) {
        let router = RoomRouter.createRoom
        
        var param = ["roomNm": roomName]
        
        AF.request(router.url, method: router.method, parameters: param, encoding: JSONEncoding.default, headers: router.headers)
//            .validate(statusCode: 200..<500)
            .responseDecodable(of: CreateRoomResponse.self) { response in
                print(response)
                print(param)
                switch response.result {
                    // 성공인 경우
                case .success(let result):
                    print("룸 생성 데이터 전송 성공 - \(result)")
                    let status = CreateRoomResponse.Status(rawValue: result.code)
                    if status == .success {
                        completion(result.data?.detailResponse.roomId)
                    } else {
                        // ToDo - 에러처리
                        completion(nil)
                    }
                    
                case .failure(let error):
                    print("룸 생성 데이터 전송 실패 - \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }
}


//MARK: - 룸 생성 Output
struct CreateRoomResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let data: CreateRoomData?
}

//MARK: - 룸 조회 Input
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

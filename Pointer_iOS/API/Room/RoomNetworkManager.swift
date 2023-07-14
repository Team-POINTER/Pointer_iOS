//
//  RoomNetworkManager.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/13.
//

import Foundation
import Alamofire
import RxSwift

class RoomNetworkManager {
    
//MARK: - shared
    static let shared = RoomNetworkManager()
    let router = RoomRouter.self
    
    
//MARK: - Observable 변환
    func searchRoomRequest(_ roomId: Int) -> Observable<SearchRoomResultData> {
        return Observable.create { (observer) -> Disposable in
            self.searchRoomRequest(roomId) { error, searchRoomResultData in
                if let error = error {
                    observer.onError(error)
                }
                
                if let data = searchRoomResultData {
                    observer.onNext(data)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
//MARK: - Function
    private func searchRoomRequest(_ roomId: Int,_ completion: @escaping (Error?, SearchRoomResultData?) -> Void){
        
        AF.request(router.getSingleRoom(roomId).url, method: router.getSingleRoom(roomId).method, headers: router.getSingleRoom(roomId).headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: SearchRoomResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(nil, result.data)
                // 실패인 경우
                case .failure(let error):
                    print("룸 조회 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
    
}


//MARK: - 룸(하나) 조회 Result Model
struct SearchRoomResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let data: SearchRoomResultData
}

struct SearchRoomResultData: Decodable {
    let roomId: Int
    let roomNm: String
    let memberNum: Int
    let votingNum: Int
    let question: String
    let limitedAt: String
    let roomMembers: [SearchRoomMembers]
}

struct SearchRoomMembers: Decodable {
    let userId: Int
    let id: String
    let name: String
    let privateRoomNm: String
}

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
    let roomRouter = RoomRouter.self
    let questionRouter = QuestionRouter.self
    
    
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
    
    func currentQuestionRequest(_ roomId: Int) -> Observable<SearchQuestionResultData> {
        return Observable.create { (observer) -> Disposable in
            
            self.currentQuestionRequest(roomId) { error, searchQuestionResultData in
                if let error = error {
                    observer.onError(error)
                }
                
                if let data = searchQuestionResultData {
                    observer.onNext(data)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
//MARK: - Function
    // 룸 하나 조회
    private func searchRoomRequest(_ roomId: Int,_ completion: @escaping (Error?, SearchRoomResultData?) -> Void){
        
        AF.request(roomRouter.getSingleRoom(roomId).url, method: roomRouter.getSingleRoom(roomId).method, headers: roomRouter.getSingleRoom(roomId).headers)
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
    
    // 현재 질문 조회 - 이거 적용 중
    private func currentQuestionRequest(_ roomId: Int, completion: @escaping (Error?, SearchQuestionResultData?) -> Void){
        let userId = TokenManager.getIntUserId()
        
        AF.request(questionRouter.currentSearchQuestion(userId, roomId).url,
                   method: questionRouter.currentSearchQuestion(userId, roomId).method,
                   headers: questionRouter.currentSearchQuestion(userId, roomId).headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: SearchQuestionResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    guard let data = result.result else { return }
                    completion(nil, data)
                // 실패인 경우
                case .failure(let error):
                    print("현재 질문 조회 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
    
}


//MARK: - #1-1 룸(하나) 조회 Result Model
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

//MARK: - #1-1 질문 API
struct SearchQuestionResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: SearchQuestionResultData?
}

struct SearchQuestionResultData: Decodable {
    let roomName: String
    let questionId: Int
    let content: String
    let members: [SearchQuestionResultMembers]
    let voted: Bool
}

struct SearchQuestionResultMembers: Decodable {
    let userId: Int
    let nickname: String
}

//MARK: - #1-1 투표하기 API
struct VoteRequestModel: Encodable {
    let questionId: Int
    let userId: Int
    let votedUserIds: [Int]
    let hint: String
}

struct VoteResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: [VoteResultData]?
}

struct VoteResultData: Decodable {
    let id: Int
    let questionId: Int
    let userId: Int
    let votedUserId: Int
    let hint: String
}

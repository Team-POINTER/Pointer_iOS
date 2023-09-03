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
    let voteRouter = VoteRouter.self
    
    
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
    // 룸 하나 조회 - 이거 적용 중
    private func searchRoomRequest(_ roomId: Int,_ completion: @escaping (Error?, SearchRoomResultData?) -> Void){
        let singleRoom = roomRouter.getSingleRoom(roomId)
        
        AF.request(singleRoom.url,
                   method: singleRoom.method,
                   headers: singleRoom.headers)
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
    
    // 현재 질문 조회
    private func currentQuestionRequest(_ roomId: Int, completion: @escaping (Error?, SearchQuestionResultData?) -> Void){
        let currentQuestion = questionRouter.currentSearchQuestion(roomId)
        
        AF.request(currentQuestion.url,
                   method: currentQuestion.method,
                   headers: currentQuestion.headers)
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
    
    // 투표하기
    func voteRequest(_ parameters: VoteRequestModel, completion: @escaping (Error?, [VoteResultData]?) -> Void){
        let vote = voteRouter.vote
        
        AF.request(vote.url,
                   method: vote.method,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: vote.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: VoteResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    print(result)
                    guard let data = result.result else { return }
                    completion(nil, data)
                // 실패인 경우
                case .failure(let error):
                    print("투표하기 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
    
    // 룸 초대
    func invteFriendRequest(_ parameters: InviteFriendRequestModel, completion: @escaping (Error?, PointerResultModel?) -> Void) {
        let router = roomRouter.inviteMemeber
        
        AF.request(router.url,
                   method: router.method,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointerResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(nil, result)
                // 실패인 경우
                case .failure(let error):
                    print("룸 초대 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
    
    // 룸 초대 (링크)
    func inviteFriendWithLinkRequest(_ roomId: Int, completion: @escaping (Error?, String?) -> Void) {
        let router = roomRouter.inviteMemberLink(roomId)
        
        AF.request(router.url,
                   method: router.method,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: InviteFriendWithLinkResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    let link = result.data
                    completion(nil, link)
                // 실패인 경우
                case .failure(let error):
                    print("룸 초대 (링크) 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
    
    // 초대 가능한 친구 목록
    func inviteFriendListRequest(roomId: Int, keyword: String, lastPage: Int,
                                 completion: @escaping (Error?, FriendsListResultModel?) -> Void) {
        let inviteFriendsList = roomRouter.friendsListToAttend(roomId: roomId, keyword: keyword, lastPage: lastPage)
        
        AF.request(inviteFriendsList.url,
                   method: inviteFriendsList.method,
                   headers: inviteFriendsList.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: FriendsListResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(nil, result)
                // 실패인 경우
                case .failure(let error):
                    print("친구 목록 조회 데이터 전송 실패 - \(error.localizedDescription)")
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
    let data: SearchRoomResultData?
}

struct SearchRoomResultData: Decodable {
    let roomId: Int
    let privateRoomNm: String
    let memberNum: Int
    let votingNum: Int
    let questionId: Int
    let question: String
    let questionCreatorId: Int
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

//MARK: - 초대 가능한 친구 목록
struct InviteFriendsListReqeustInputModel: Encodable {
    let keyword: String
    let lastPage: Int
}

struct FriendsListResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let friendList: [FriendsListResultData]
    let total: Int
    let currentPage: Int
}

struct FriendsListResultData: Decodable {
    let friendId: Int
    let id: String
    let friendName: String
    let file: String?
    let status: Int
}

// MARK: - 룸 초대하기
struct InviteFriendRequestModel: Encodable {
    let roomId: Int
    let userFriendIdList: [Int]
}

//MARK: - 룸 초대하기 (링크)
struct InviteFriendWithLinkResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let data: String
}

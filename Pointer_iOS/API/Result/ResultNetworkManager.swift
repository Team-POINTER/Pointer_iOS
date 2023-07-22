//
//  ResultNetworkManager.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/15.
//

import Foundation
import Alamofire
import RxSwift

class ResultNetworkManager {
    
//MARK: - shared
    static let shared = ResultNetworkManager()
    let questionRouter = QuestionRouter.self
    let voteRouter = VoteRouter.self
    let userId = TokenManager.getIntUserId()
    
    
//MARK: - Observable 변환
    func votedResultRequest(_ questionId: Int) -> Observable<VotedResultData> {
        return Observable.create { (observer) -> Disposable in
            
            self.votedResultRequest(questionId) { error, votedResultData in
                if let error = error {
                    observer.onError(error)
                }
                
                if let data = votedResultData {
                    observer.onNext(data)
                }
                
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func totalQuestionRequest(_ roomId: Int) -> Observable<[TotalQuestionResultData]> {
        return Observable.create { (observer) -> Disposable in
            
            self.totalQuestionRequest(roomId) { error, totalQuestionResultData in
                if let error = error {
                    observer.onError(error)
                }
                
                if let data = totalQuestionResultData {
                    observer.onNext(data)
                }
                
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func showHintRequest(_ questionId: Int) -> Observable<ShowHintResultData> {
        return Observable.create { (observer) -> Disposable in
            
            self.showHintRequest(questionId) { error, showHintResultData in
                if let error = error {
                    observer.onError(error)
                }
                
                if let data = showHintResultData {
                    observer.onNext(data)
                }
                
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
//MARK: - Function
    
    // 지목화면 결과 조회
    private func votedResultRequest(_ questionId: Int, _ completion: @escaping (Error?, VotedResultData?) -> Void){
        AF.request(voteRouter.votedResult(userId, questionId).url,
                   method: voteRouter.votedResult(userId, questionId).method,
                   headers: voteRouter.votedResult(userId, questionId).headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: VotedResultModel.self) { response in
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
    
    private func totalQuestionRequest(_ roomId: Int, completion: @escaping(Error?, [TotalQuestionResultData]?) -> Void) {
        AF.request(questionRouter.totalSearchQuestion(userId, roomId).url,
                   method:questionRouter.totalSearchQuestion(userId, roomId).method,
                   headers: questionRouter.totalSearchQuestion(userId, roomId).headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: TotalQuestionResultModel.self) { response in
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
    
    private func showHintRequest(_ questionId: Int, completion: @escaping(Error?, ShowHintResultData?) -> Void) {
        AF.request(voteRouter.showHint(userId, questionId).url,
                   method:voteRouter.showHint(userId, questionId).method,
                   headers: voteRouter.showHint(userId, questionId).headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: ShowHintResultModel.self) { response in
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
    
}


//MARK: - #1-2 지목화면 결과 조회
struct VotedResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: VotedResultData?
}

struct VotedResultData: Decodable {
    let roomName: String
    let question: String
    let targetUser: VotedUser // 해당 유저
    let members: [VotedUser] // 룸 안 유저
    let notNotedMemberCnt: Int // 투표하지 않은 유저 수
    let notReadChatCnt: Int
}

struct VotedUser: Decodable {
    let userId: Int
    let userName: String
    let allVoteCnt: Int // 모든 투표 수
    let votedMemberCnt: Int // 해당 유저가 받은 투표 수
}

//MARK: - #1-3 질문 전체 조회
struct TotalQuestionResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: [TotalQuestionResultData]?
}

struct TotalQuestionResultData: Decodable {
    let roomName: String?
    let questionId: Int
    let question: String
    let allVoteCnt: Int
    let votedMemberCnt: Int
    let createdAt: String
}

//MARK: - #1-4 힌트 보기
struct ShowHintResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: ShowHintResultData?
}

struct ShowHintResultData: Decodable {
    let hint: [String]
    let allVoteCnt: Int // 모든 투표 수
    let targetVotedCnt: Int // 받은 투표 수
    let createdAt: String
}

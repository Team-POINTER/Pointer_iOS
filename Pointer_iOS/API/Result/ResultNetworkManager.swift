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
        AF.request(voteRouter.votedResult(questionId).url,
                   method: voteRouter.votedResult(questionId).method,
                   headers: voteRouter.votedResult(questionId).headers)
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
                print("지목화면 결과 데이터 전송 실패 - \(error.localizedDescription)")
                // completion 전송
                completion(error, nil)
            }
        }
    }
    
    private func totalQuestionRequest(_ roomId: Int, completion: @escaping (Error?, [TotalQuestionResultData]?) -> Void) {
        AF.request(questionRouter.totalSearchQuestion(roomId).url,
                   method:questionRouter.totalSearchQuestion(roomId).method,
                   headers: questionRouter.totalSearchQuestion(roomId).headers)
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
                print("질문 전체 조회 데이터 전송 실패 - \(error.localizedDescription)")
                // completion 전송
                completion(error, nil)
            }
        }
    }
    
    private func showHintRequest(_ questionId: Int, completion: @escaping (Error?, ShowHintResultData?) -> Void) {
        AF.request(voteRouter.showHint(questionId).url,
                   method:voteRouter.showHint(questionId).method,
                   headers: voteRouter.showHint(questionId).headers)
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
                print("힌트보기 데이터 전송 실패 - \(error.localizedDescription)")
                // completion 전송
                completion(error, nil)
            }
        }
    }
    
    func newQuestionRequest(_ parameters: NewQuestionRequestModel,
                            completion: @escaping (Error?, NewQuestionResultModel?) -> Void) {
        AF.request(questionRouter.createQuestion.url,
                   method:questionRouter.createQuestion.method,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: questionRouter.createQuestion.headers)
        .validate(statusCode: 200..<500)
        .responseDecodable(of: NewQuestionResultModel.self) { response in
            switch response.result {
                // 성공인 경우
            case .success(let result):
                // completion 전송
                print(result)
                completion(nil, result)
                // 실패인 경우
            case .failure(let error):
                print("새 질문 등록 데이터 전송 실패 - \(error.localizedDescription)")
                // completion 전송
                completion(error, nil)
            }
        }
    }
    
    func deleteHintRequest(_ parameters: DeleteHintRequestModel, completion: @escaping (Error?, DeleteResultModel?) -> Void) {
        let router = voteRouter.deleteHint
        AF.request(router.url,
                   method: router.method,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: router.headers)
        .validate(statusCode: 200..<500)
        .responseDecodable(of: DeleteResultModel.self) { response in
            switch response.result {
                // 성공인 경우
            case .success(let result):
                // completion 전송
                completion(nil, result)
                // 실패인 경우
            case .failure(let error):
                print("새 질문 등록 데이터 전송 실패 - \(error.localizedDescription)")
                // completion 전송
                completion(error, nil)
            }
        }
    }
    
    func checkCreatableQuestionRequest(_ roomId: Int, completion: @escaping (Error?, CheckCreatableQuestionResultModel?) -> Void) {
        let router = questionRouter.checkCreatableQuestion(roomId)
        AF.request(router.url,
                   method: router.method,
                   headers: router.headers)
        .validate(statusCode: 200..<500)
        .responseDecodable(of: CheckCreatableQuestionResultModel.self) { response in
            switch response.result {
                // 성공인 경우
            case .success(let result):
                // completion 전송
                completion(nil, result)
                // 실패인 경우
            case .failure(let error):
                print("질문 생성 가능 여부 확인 데이터 전송 실패 - \(error.localizedDescription)")
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

//MARK: - #1-2 지목하지 않은 사람 조회
struct NotVotedResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: [NotVotedResultData]?
}

struct NotVotedResultData: Decodable {
    let userId: Int
    let userName: String
}

//MARK: - #1-3 질문 전체 조회
struct TotalQuestionResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: [TotalQuestionResultData]?
}

struct TotalQuestionResultData: Decodable {
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
    let voters: [showHintResultVoters]
    let allVoteCnt: Int // 모든 투표 수
    let targetVotedCnt: Int // 받은 투표 수
    let createdAt: String
}   

struct showHintResultVoters: Decodable {
    let voteHistoryId: Int
    let voterId: Int
    let voterNm: String
    let hint: String
}

//MARK: - #1-4 힌트 삭제
struct DeleteHintRequestModel: Encodable {
    let questionId: Int
    let voterId: Int
}

struct DeleteResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
}

//MARK: - #1-5 새 질문 등록
struct NewQuestionRequestModel: Encodable {
    let roomId: Int
    let content: String
}

struct NewQuestionResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: NewQuestionResultData?
}

struct NewQuestionResultData: Decodable {
    let questionId: Int
    let content: String
}

//MARK: - #1-5 질문 생성 가능 조회
struct CheckCreatableQuestionResultModel: Decodable {
    let code: String
    let message: String
    let result: Bool
}

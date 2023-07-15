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
    let voteRouter = VoteRouter.self
    
    
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
    
//MARK: - Function
    
    // 지목화면 결과 조회
    private func votedResultRequest(_ questionId: Int, _ completion: @escaping (Error?, VotedResultData?) -> Void){
        let userId = TokenManager.getIntUserId()
        
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

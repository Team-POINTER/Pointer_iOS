//
//  ReportNetworkManager.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/14.
//

import Foundation
import Alamofire
import RxSwift

class ReportNetworkManager {
    
//MARK: - shared
    static let shared = ReportNetworkManager()
    let reportRouter = ReportRouter.self
    
    
//MARK: - Observable 변환
    
    
//MARK: - Function
    
    // 신고하기
    func reportRequest(parameter: ReportRequestModel, _ completion: @escaping (Error?, ReportResultModel?) -> Void){
        let router = reportRouter.report
        
        AF.request(router.url,
                   method: router.method,
                   parameters: parameter,
                   encoder: JSONParameterEncoder.default,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: ReportResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(nil, result)
                // 실패인 경우
                case .failure(let error):
                    print("신고하기 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
    
        
}


//MARK: - 룸, 힌트 신고 생성
struct ReportRequestModel: Codable {
    let roomId: Int
    let dataId: Int
    let type: String
    let targetUserId: Int
    let reportingUserId: Int
    let reason: String
    let reasonCode: String
}

struct ReportResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: ReportRequestModel?
}


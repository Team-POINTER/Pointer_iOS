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
        print(parameter)
        
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
    
    // 유저 신고하기
    func userReportRequest(parameter: UserReportRequestModel, _ completion: @escaping (Error?, UserReportResultModel?) -> Void){
        let router = reportRouter.userReport
        
        AF.request(router.url,
                   method: router.method,
                   parameters: parameter,
                   encoder: JSONParameterEncoder.default,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: UserReportResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(nil, result)
                // 실패인 경우
                case .failure(let error):
                    print("유저 신고하기 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
}


//MARK: - 룸, 힌트 신고 생성
struct ReportRequestModel: Encodable {
    let roomId: Int
    let dataId: Int
    let type: String
    let targetUserId: Int
    let reason: String
    let reasonCode: String
}

struct ReportResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: ReportRusultData?
}

struct ReportRusultData: Decodable {
    let roomId: Int
    let data: String
    let type: String
    let targetUserId: Int
    let reportingUserId: Int
    let reason: String
    let reasonCode: String
}

//MARK: - 유저 신고 생성
struct UserReportRequestModel: Encodable {
    let targetUserId: Int
    let reason: String
    let reasonCode: String
}

struct UserReportResultModel: Decodable {
    let status: Int?
    let code: String
    let message: String
    let result: UserReportResultData?
}

struct UserReportResultData: Decodable {
    let targetUserId: Int
    let reportingUserId: Int
    let reason: String
    let reasonCode: String
}

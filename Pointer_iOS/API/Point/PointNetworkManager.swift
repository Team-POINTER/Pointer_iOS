//
//  PointNetworkManager.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/20.
//

import Foundation
import Alamofire
import UIKit

class PointNetworkManager {

//MARK: - shared
    static let shared = PointNetworkManager()
    let pointRouter = PointRouter.self
    
    
//MARK: - Function
    // 포인트 사용 문구 확인
    func checkPointRequest(_ completion: @escaping (Error?, PointResultModel?) -> Void){
        let router = pointRouter.checkPoint
        
        AF.request(router.url,
                   method: router.method,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(nil, result)
                // 실패인 경우
                case .failure(let error):
                    print("포인트 문구 확인 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
    
    // 포인트 차감
    func usePointRequest(point: Int, _ completion: @escaping (Error?, PointResultModel?) -> Void){
        let router = pointRouter.usePoint(point)
        
        AF.request(router.url,
                   method: router.method,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointResultModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(nil, result)
                // 실패인 경우
                case .failure(let error):
                    print("포인트 차감 데이터 전송 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(error, nil)
                }
            }
    }
    
}

struct PointResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let point: Int
}

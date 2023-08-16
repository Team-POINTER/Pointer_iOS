//
//  RemotePushRouter.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/15.
//

import Foundation
import Alamofire

enum RemotePushRouter {
    /// 푸시 등록
    case registerPush
    /// 알림 활성화 여부 조회
    case getPushEnableStatus
    /// 전체 알림 활성화/비활성화
    case totalNotiEnable
    /// 활동 알림 활성화/비활성화
    case activityNotiEnable
    /// 채팅 알림 활성화/비활성화
    case chatNotiEnable
    /// 이벤트 알림 활성화/비활성화
    case eventNotiEnable
    /// Room 알림 리스트 조회
    case getRoomPushList(lastPage: Int)
    /// Friend 알림 리스트 조회
    case getFriendPushList(lastPage: Int)
}

extension RemotePushRouter: HttpRouter {
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return Secret.baseURL
    }
    
    var path: String {
        switch self {
        case .registerPush:
            return "/alarm/kakao"
        case .getPushEnableStatus:
            return "/alarm/all/active"
        case .totalNotiEnable:
            return "/alarm/all"
        case .activityNotiEnable:
            return "/alarm/active"
        case .chatNotiEnable:
            return "/alarm/chat"
        case .eventNotiEnable:
            return "/alarm/event/active"
        case .getRoomPushList(let lastPage):
            return "/alarm/\(lastPage)"
        case .getFriendPushList(let lastPage):
            return "/alarm/friend/\(lastPage)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .registerPush:
            return .post
        case .getPushEnableStatus:
            return .get
        case .totalNotiEnable, .activityNotiEnable, .chatNotiEnable, .eventNotiEnable:
            return .post
        case .getRoomPushList, .getFriendPushList:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        guard let accessToken = TokenManager.getUserAccessToken() else { return HTTPHeaders() }
        return ["Content-Type" : "application/json",
                "Authorization" : "Bearer \(accessToken)"]
    }
    
    var successCode: String {
        switch self {
        default:
            return "A200"
        }
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    func body() throws -> Data? {
        return nil
    }
    
    func getStatusParam(_ value: Bool) -> Parameters {
        return ["active": value]
    }
}


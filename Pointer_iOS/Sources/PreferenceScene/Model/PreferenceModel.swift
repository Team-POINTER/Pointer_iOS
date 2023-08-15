//
//  PreferenceModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import Foundation

enum PreferenceSectionType: Int, CaseIterable {
    case personal = 0
    case information = 1
    case etc = 2
    
    var title: String {
        switch self {
        case .personal:
            return "개인 설정"
        case .information:
            return "이용 안내"
        case .etc:
            return "기타"
        }
    }
}

enum PreferenceMenuType: Int, CaseIterable {
    // 메뉴들
    case totalNotification = 0
    case chattingNotification = 1
    case activityNotification = 2
    case eventNotification = 3
    case viewMode = 4

    case appVersion = 5
    case inquire = 6
    case notice = 7
    case serviceTerms = 8
    case privacyTerms = 9
    case openSourceLicense = 10

    case blockedUser = 11
    case removeAccount = 12
    case signOut = 13
    
    var title: String {
        switch self {
        case .totalNotification:
            return "알림 전체 설정"
        case .chattingNotification:
            return "채팅 알림"
        case .activityNotification:
            return "활동 알림"
        case .eventNotification:
            return "이벤트 알림"
        case .viewMode:
            return "모드 변경"
        case .appVersion:
            return "앱 버전"
        case .inquire:
            return "문의하기"
        case .notice:
            return "공지사항"
        case .serviceTerms:
            return "서비스 이용약관"
        case .privacyTerms:
            return "개인정보 처리방침"
        case .openSourceLicense:
            return "오픈소스 라이선스"
        case .blockedUser:
            return "차단한 사용자 목록"
        case .removeAccount:
            return "회원 탈퇴"
        case .signOut:
            return "로그아웃"
        }
    }
    
    // 각 타입별 섹션
    var section: PreferenceSectionType {
        switch self {
        case .totalNotification, .chattingNotification, .activityNotification, .eventNotification, .viewMode:
            return .personal
        case .appVersion, .inquire, .notice, .serviceTerms, .privacyTerms, .openSourceLicense:
            return .information
        case .blockedUser, .removeAccount, .signOut:
            return .etc
        }
    }
    
    // SubTitle
    var subTitle: String? {
        return nil
    }
    
    // 각 토글 메뉴 사용 여부
    var toggleIsAvailable: Bool {
        switch self {
        case .totalNotification, .chattingNotification, .activityNotification, .eventNotification:
            return true
        default: return false
        }
    }
    
    var toggleKey: String? {
        switch self {
        case .chattingNotification: return "chatAlarm"
        case .activityNotification: return "activeAlarm"
        case .eventNotification: return "eventAlarm"
        default: return nil
        }
    }
    
    var router: RemotePushRouter? {
        switch self {
        case .totalNotification: return .totalNotiEnable
        case .chattingNotification: return .chatNotiEnable
        case .activityNotification: return .activityNotiEnable
        case .eventNotification: return .eventNotiEnable
        default:
            return nil
        }
    }
}

struct PreferenceModel {
    var menu: PreferenceMenuType
    var isToggleEnabled: Bool = false
}

extension PreferenceModel {
    static func getPreferenceData() -> [PreferenceModel] {
        let resultArray = PreferenceMenuType.allCases.map { PreferenceModel(menu: $0) }
        return resultArray
    }
}

//MARK: - ToggleInfo
struct PreferenceToggleConfig {
    let isAvailable: Bool
    var isEnabled: Bool
    let router: RemotePushRouter?
}

//MARK: - RemotePush 조회 response
struct RemotePushInfoResponse: Codable {
    let code, message: String
    let result: RemotePushInfoResult
}

struct RemotePushInfoResult: Codable {
    let allAlarm: Bool
    let activeAlarm: Bool
    let chatAlarm: Bool
    let eventAlarm: Bool
}

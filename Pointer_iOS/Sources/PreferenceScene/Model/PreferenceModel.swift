//
//  PreferenceModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import Foundation

enum PreferenceModel: String, CaseIterable {
    
    enum SectionType: String, CaseIterable {
        case personal = "개인 설정"
        case information = "이용 안내"
        case etc = "기타"
    }
    
    // 메뉴들
    case notification = "알림 설정"
    case viewMode = "모드 변경"
    case appVersion = "앱 버전"
    case inquire = "문의하기"
    case notice = "공지사항"
    case serviceTerms = "서비스 이용약관"
    case privacyTerms = "개인정보 처리방침"
    case openSourceLicense = "오픈소스 라이선스"
    case removeAccount = "회원 탈퇴"
    case signOut = "로그아웃"
    
    // 각 타입별 섹션
    var type: SectionType {
        switch self {
        case .notification, .viewMode:
            return .personal
        case .appVersion, .inquire, .notice, .serviceTerms, .privacyTerms, .openSourceLicense:
            return .information
        case .removeAccount, .signOut:
            return .etc
        }
    }
    
    // subTitle
    var subTitle: String? {
        switch self {
        case .viewMode: return "다크"
        case .appVersion: return "6.4.1"
        default: return nil
        }
    }
    
    // 각 메뉴들의 액션 핸들러
    var handler: (() -> Void)? {
        switch self {
        default:
            return nil
        }
    }
}

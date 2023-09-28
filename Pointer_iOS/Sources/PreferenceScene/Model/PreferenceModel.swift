//
//  PreferenceModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit
import SafariServices

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

    case appVersion = 4
    case inquire = 5
    case notice = 6
    case serviceTerms = 7
    case privacyTerms = 8
    case openSourceLicense = 9

    case blockedUser = 10
    case removeAccount = 11
    case signOut = 12
    
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
        case .totalNotification, .chattingNotification, .activityNotification, .eventNotification:
            return .personal
        case .appVersion, .inquire, .notice, .serviceTerms, .privacyTerms, .openSourceLicense:
            return .information
        case .blockedUser, .removeAccount, .signOut:
            return .etc
        }
    }
    
    // SubTitle
    var subTitle: String? {
        switch self {
        case .appVersion:
            return Util.appVersion
        default:
            return nil
        }
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
    
    var nextViewController: UIViewController? {
        switch self {
        case .appVersion:
            return nil
        case .inquire:
            guard let url = URL(string: "https://forms.gle/vYhdBbQ8Pea6oi2Q6") else { return nil }
            let vc = SFSafariViewController(url: url)
            return vc
        case .notice:
            guard let url = URL(string: "https://pointer2024.notion.site/pointer2024/POINTER-a690c831dc524434946b0e16239ce593") else { return nil }
            let vc = SFSafariViewController(url: url)
            return vc
        case .serviceTerms:
            guard let url = URL(string: "https://pointer2024.notion.site/d55d0a2334d549e9a17477bc6ade3bb0?pvs=4") else { return nil }
            let vc = SFSafariViewController(url: url)
            return vc
        case .privacyTerms:
            guard let url = URL(string: "https://pointer2024.notion.site/4936ea14737f44018b2d798db4e64d0a?pvs=4") else { return nil }
            let vc = SFSafariViewController(url: url)
            return vc
        case .openSourceLicense:
            guard let url = URL(string: "https://github.com/Team-POINTER/Pointer_iOS") else { return nil }
            let vc = SFSafariViewController(url: url)
            return vc
        case .blockedUser:
            let vc = BlockedFriendListController(viewModel: BlockedFriendListViewModel())
            let nav = BaseNavigationController.templateNavigationController(nil, viewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            return nav
        case .removeAccount:
            let vc = RemoveAccountController()
            let nav = BaseNavigationController.templateNavigationController(nil, viewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            return nav
        case .signOut:
            let alert = PointerAlert.getActionAlert(title: "로그아웃", message: "저장된 모든 정보는 재로그인시 유지돼요. 정말 로그아웃 하시겠습니까?", actionTitle: "로그아웃") { _ in
                sceneDelegate?.appCoordinator?.logout()
            }
            return alert
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
    let activeAlarm: Bool
    let chatAlarm: Bool
    let eventAlarm: Bool
}

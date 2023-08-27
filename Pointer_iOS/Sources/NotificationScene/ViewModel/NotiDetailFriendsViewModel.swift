//
//  NotiDetailFriendsViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class NotiDetailFriendsViewModel: NotiDetailViewModel {
    
    //MARK: - Properties
    var dataSources = BehaviorRelay<[Any]>(value: [])
    var nextViewController = PublishRelay<UIViewController?>()
    var disposeBag = DisposeBag()
    
    let network = RemotePushManager()
    
    //MARK: - Methods
    func notificationItemTapped(type: NotificationDetailViewController.NotiType, item: Any) {
        switch type {
        case .friends:
            guard let item = item as? FriendAlarmList,
                  let notiType = PushType(rawValue: item.type) else { return }
            
            // Notification Type에 따른 분기
            switch notiType {
            case .friendAccept, .friendRequest:
                // 프로필 뷰로 이동
                let profileVc = notiType.getNextViewController(id: item.userId)
                self.nextViewController.accept(profileVc)
            default:
                break
            }
            
        default: return
        }
    }
    
    //MARK: - API
    func requestData() {
        network.requestFriendNotiDetailList { [weak self] list in
            self?.dataSources.accept(list)
        }
    }
}

//
//  NotificationDetailRoomViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class NotiDetailRoomViewModel: NotiDetailViewModel {
    
    //MARK: - Properties
    weak var delegate: NewNotiIconDelegate?
    var dataSources = BehaviorRelay<[Any]>(value: [])
    var nextViewController = PublishRelay<UIViewController?>()
    var disposeBag = DisposeBag()
    
    let network = RemotePushManager()
    
    //MARK: - Methods
    func notificationItemTapped(type: NotificationDetailViewController.NotiType, item: Any) {
        switch type {
            
        // Room 노티만 다룸
        case .room:
            
            guard let item = item as? RoomAlarmList,
                  let notiType = PushType(rawValue: item.type) else { return }
            
            // Notification Type에 따른 분기
            switch notiType {
            case .friendAccept, .friendRequest:
                // 프로필 뷰로 이동
                let profileVc = notiType.getNextViewController(id: item.sendUserId)
                self.nextViewController.accept(profileVc)
                
            case .poke, .question:
                // 룸으로 이동
                let roomVc = notiType.getNextViewController(id: item.needId)
                self.nextViewController.accept(roomVc)
            default:
                break
            }
            
        default: return
        }
    }
    
    //MARK: - API
    func requestData() {
        network.requestRoomNotiDetailList { [weak self] response in
            guard let response = response else { return }
            self?.dataSources.accept(response.result.alarmList)
            self?.delegate?.newNotiStatus(room: false, friend: true)
            if response.result.newFriendAlarm {
                self?.delegate?.newNotiStatus(room: false, friend: true)
            }
        }
    }
}

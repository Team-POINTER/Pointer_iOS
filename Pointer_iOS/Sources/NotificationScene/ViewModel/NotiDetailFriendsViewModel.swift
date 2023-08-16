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
    var disposeBag = DisposeBag()
    let network = RemotePushManager()
    
    //MARK: - API
    func requestData() {
        network.requestFriendNotiDetailList { [weak self] list in
            self?.dataSources.accept(list)
        }
    }
}

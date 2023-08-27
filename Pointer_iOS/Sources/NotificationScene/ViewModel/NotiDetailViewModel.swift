//
//  NotiDetailViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

protocol NotiDetailViewModel {
    var dataSources: BehaviorRelay<[Any]> { get set }
    var disposeBag: DisposeBag { get set }
    var nextViewController: PublishRelay<UIViewController?> { get set }
    
    func requestData()
    func notificationItemTapped(type: NotificationDetailViewController.NotiType, item: Any)
}

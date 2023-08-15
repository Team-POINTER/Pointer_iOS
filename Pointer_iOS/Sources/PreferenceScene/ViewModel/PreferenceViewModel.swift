//
//  PreferenceViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit
import RxCocoa
import RxRelay
import RxSwift

class PreferenceViewModel: ViewModelType {
    //MARK: - In/Out
    struct Input {
        let collectionItemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let nextViewController = BehaviorRelay<UIViewController?>(value: nil)
    }
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    let network = RemotePushManager()
    
    let preferenceData = BehaviorRelay<[PreferenceModel]>(value: PreferenceModel.getPreferenceData())
    let pushInfoData = BehaviorRelay<RemotePushInfoResult?>(value: nil)
    
    //MARK: - Computed Properties
    
    
    //MARK: - RxSwift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        // CollectionView Item 선택 이벤트 바인딩
        input.collectionItemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let item = self.indexPathToType(indexPath)
                print(item.menu.title)
            })
            .disposed(by: disposeBag)
        
        requestPushInfoData()
        return output
    }
    
    func indexPathToType(_ indexPath: IndexPath) -> PreferenceModel {
        let section = PreferenceSectionType(rawValue: indexPath.section)
        let models = preferenceData.value.filter { $0.menu.section == section }
        let item = models[indexPath.row]
        return item
    }
    
    //MARK: - API
    func requestPushInfoData() {
        // 푸시 정보 request
        network.getRemotePushInfo { [weak self] result in
            guard let self = self,
                  let result = result else { return }
            
            var trueCount = 0
            var newData = self.preferenceData.value
            var totalNotiElementIndex: Int?
            
            newData.enumerated().forEach { index, data in
                // chatting 상태
                if data.menu == .chattingNotification {
                    newData[index].isToggleEnabled = result.chatAlarm
                    if result.chatAlarm == true {
                        trueCount += 1
                    }
                }
                // 활동 알림 상태
                if data.menu == .activityNotification {
                    newData[index].isToggleEnabled = result.activeAlarm
                    if result.activeAlarm == true {
                        trueCount += 1
                    }
                }
                // event 알림 상태
                if data.menu == .eventNotification {
                    newData[index].isToggleEnabled = result.eventAlarm
                    if result.eventAlarm == true {
                        trueCount += 1
                    }
                }
                // 알림 전체 설정 index
                if data.menu == .totalNotification {
                    totalNotiElementIndex = index
                }
            }
            
            // 전체 설정 토글 뷰
            if let totalNotiIndex = totalNotiElementIndex {
                if trueCount == 3 {
                    newData[totalNotiIndex].isToggleEnabled = true
                } else {
                    newData[totalNotiIndex].isToggleEnabled = false
                }
            }
            
            // 새로운 데이터 accept
            self.preferenceData.accept(newData)
        }
    }
}

extension PreferenceViewModel: PreferenceItemDelegate {
    func pushToggleTapped(item: PreferenceModel, value: Bool) {
        
        print("\(item.menu.title)의 value: \(value)")
        let targetStatus = value ? false : true
        guard let router = item.menu.router else { return }
        network.requestTogglePushStatus(status: targetStatus, router: router) { [weak self] isSuccessed in
            if isSuccessed {
                self?.requestPushInfoData()
            } else {
                print("실패..")
            }
        }
    }
}

//
//  BlockedFriendViewModel.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/27.
//

import Foundation
import RxSwift
import RxRelay

class BlockedFriendListViewModel: ViewModelType {
    //MARK: - RxSwift In/Out
    struct Input {
        /// 헤더뷰 텍스트필드 입력 이벤트
        let searchTextFieldEditEvent: Observable<String?>
    }
    
    struct Output {

    }
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    /// 차단 유저 배열
    public let userList = BehaviorRelay<[FriendsModel]>(value: [])
    private let network = FriendNetworkManager()
    
    //MARK: - Bind
    func transform(input: Input) -> Output {
        input.searchTextFieldEditEvent
            .bind { [weak self] keyword in
                self?.requestBlockedFriendList(keyword: keyword)
            }
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    //MARK: - Methods
    func requestBlockedFriendList(keyword: String? = nil) {
        network.requestBlockedFriendsList(keyword: keyword ?? "", lastPage: 0) { [weak self] list in
            if let friends = list {
                self?.userList.accept(friends)
            } else {
                print("에러발생")
            }
        }
    }
}

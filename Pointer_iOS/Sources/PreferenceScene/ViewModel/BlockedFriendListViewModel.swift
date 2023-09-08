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
    
    let reFetchBlockedFriendList = BehaviorRelay<Void?>(value: nil)
    private var hasCalledAPI = false
    
    private var lastArrayCount: Int?
    private var lastIndex: Bool = false
    private var nextPage: Int?
    private var searchText: String?
    
    //MARK: - Bind
    func transform(input: Input) -> Output {
        input.searchTextFieldEditEvent
            .bind { [weak self] keyword in
                self?.searchText = keyword
                self?.requestBlockedFriendList(keyword: keyword)
            }
            .disposed(by: disposeBag)
        
        reFetchBlockedFriendList
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                if self.hasCalledAPI == false {
                    self.hasCalledAPI = true
                    if self.lastIndex {
                        print("마지막 인덱스입니다.")
                    } else {
                        self.reFetchrequestBlockedFriendList(keyword: self.searchText, lastPage: self.nextPage)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    //MARK: - Methods
    func requestBlockedFriendList(keyword: String? = nil) {
        network.requestBlockedFriendsList(keyword: keyword ?? "", lastPage: 0) { [weak self] model in
            if let model = model {
                
                self?.userList.accept(model.friendInfoList)
            } else {
                print("에러발생")
            }
        }
    }
    
    func reFetchrequestBlockedFriendList(keyword: String? = nil, lastPage: Int?) {
        network.requestBlockedFriendsList(keyword: keyword, lastPage: lastPage ?? 1) { [weak self] model in
            guard let self = self else { return }
            
            if let model = model {
                if model.friendInfoList.isEmpty {
                    self.lastIndex = true
                } else {
                    var userListModel = self.userList.value
                    userListModel.append(contentsOf: model.friendInfoList)
                    self.userList.accept(userListModel)
                    self.nextPage = model.currentPage + 1
                    self.lastArrayCount = model.friendInfoList.count
                }
                self.hasCalledAPI = false
            } else {
                print("에러발생")
            }
        }
    }
}

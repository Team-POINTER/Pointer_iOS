//
//  SearchViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/09.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
//MARK: - Properties
    let disposeBag = DisposeBag()
    let searchRoomResult = PublishRelay<PointerRoomListModel>()
    let searchAccountResult = PublishRelay<[SearchUserListModel]>()
    
    private var currentPage = 0
    
    var lastSearchedKeyword = ""
 
//MARK: - In/Out
    struct Input {
        let searchBarTextEditEvent: Observable<String>
    }
    
    struct Output {
        
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.searchBarTextEditEvent
            .subscribe { [weak self] text in
                guard let text = text.element,
                      let self = self else { return }
                self.requestRoomList("\(text)")
                self.requestAccountList(word: "\(text)", lastPage: self.currentPage)
                self.lastSearchedKeyword = text
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Functions
 
    
    
//MARK: - Network
    // 룸 목록 조회
    func requestRoomList(_ word: String) {
        HomeNetworkManager.shared.requestRoomList(word) { [weak self] model, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let data = model?.data {
                self.searchRoomResult.accept(data)
            }
        }
    }
    
    // 유저 검색
    func requestAccountList(word: String, lastPage: Int) {
        let input = SearchUserRequestModel(keyword: word, lastPage: lastPage)
        FriendSearchNetworkManager.shared.searchUserListRequest(input) { [weak self] (model, error) in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let model = model {
                print(model.userList)
                self.searchAccountResult.accept(model.userList)
                self.currentPage = model.currentPage
            }
        }
    }
    
    // 친구 신청, 취소, 수락, 삭제, 거절, 차단, 차단 해제 - 지수님거로 변경 예정
//    func requestChangingFriendRelation(relation: FriendRelation, memberId: Int) {
//        FriendNetworkManager.shared.changeFriendRelationRequest(relation: relation, memberId: memberId) { [weak self] (model, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//            if let model = model {
//                print(model)
//            }
//        }
//    }
}


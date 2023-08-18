//
//  FriendsListViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/13.
//

import UIKit
import RxSwift
import RxCocoa

class FriendsListViewModel: ViewModelType {
    //MARK: - ListType
    enum ListType {
        case normal
        case select
    }
    
    //MARK: - Properties
    var disposeBag = DisposeBag()
    let listType: ListType
    let selectedUser = BehaviorRelay<[FriendsModel]>(value: [])
    
    let userList = BehaviorRelay<[FriendsModel]>(value: [])
    let nextViewController = BehaviorRelay<UIViewController?>(value: nil)
    
    private lazy var profileNetwork = ProfileNetworkManager()
    
    private var roomId: Int?
    private var userId: Int?
    
    //MARK: - Rx
    struct Input {
        let searchTextFieldEditEvent: Observable<String>
        let collectionViewItemSelected: Observable<IndexPath>
        let collectionViewModelSelected: Observable<FriendsModel>
    }
    
    struct Output {
        let buttonAttributeString = PublishRelay<NSAttributedString>()
    }
    
    //MARK: - Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.searchTextFieldEditEvent
            .subscribe { [weak self] text in
                guard let self = self,
                      let text = text.element else { return }
                print(text)
                
                //MARK: [FIX ME] lastPage 값이 어떤 값인가? - 무한 스크롤 시
                let model = InviteFriendsListReqeustInputModel(keyword: text, lastPage: 0)
                self.inviteFriendsListRequest(model)
            }
            .disposed(by: disposeBag)
        
        selectedUser
            .subscribe { [weak self] users in
                guard let self = self,
                      let users = users.element else { return }
                let buttonAttributeString = self.makeButtonAttributeString(count: users.count)
                output.buttonAttributeString.accept(buttonAttributeString)
            }
            .disposed(by: disposeBag)
        
        input.collectionViewModelSelected
            .subscribe { [weak self] item in
                guard let self = self,
                      let item = item.element,
                      self.listType == .normal else { return }
                let userId = item.friendId
                let viewModel = ProfileViewModel(userId: userId)
                let vc = ProfileViewController(viewModel: viewModel)
                self.nextViewController.accept(vc)
            }
            .disposed(by: disposeBag)
        
        requestFriendList()
        return output
    }
    
    //MARK: - LifeCycle
    init(listType: ListType, roomId: Int? = nil, userId: Int? = nil) {
        self.listType = listType
        self.roomId = roomId
        self.userId = userId
    }
    
    // User가 선택된 상태인지 체크하는 메소드
    private func detectSelectedUser(_ selectedUser: FriendsListResultData) -> Bool {
        var isSelectedUser = false
        for user in self.selectedUser.value {
            if user.id == selectedUser.id {
                isSelectedUser = true
                break
            }
        }
        return isSelectedUser
    }
    
    // User Select 이벤트가 들어오면 실행하는 함수
    private func processSelectedUser(selectedUser: FriendsListResultData) {
        var currentSelectedUser = self.selectedUser.value
        let isUserSelected = detectSelectedUser(selectedUser)
        switch isUserSelected {
        case true:
            currentSelectedUser.enumerated().forEach { index, user in
                if selectedUser.id == user.id {
                    currentSelectedUser.remove(at: index)
                    self.selectedUser.accept(currentSelectedUser)
                }
            }
        case false:
            break
//            currentSelectedUser.append(selectedUser)
//            self.selectedUser.accept(currentSelectedUser)
        }
    }
    
    private func makeButtonAttributeString(count: Int) -> NSAttributedString {
        let attribute = NSAttributedString(string: "\(count) 확인", attributes: [NSAttributedString.Key.font: UIFont.notoSans(font: .notoSansKrMedium, size: 18)])
        return attribute
    }
    
    func getInitialButtonAttributeString() -> NSAttributedString {
        let attribute = makeButtonAttributeString(count: selectedUser.value.count)
        return attribute
    }
    
//MARK: - API
    // 초대 가능한 친구 목록 조회
    func inviteFriendsListRequest(_ input: InviteFriendsListReqeustInputModel) {
        guard let roomId = roomId else { return }
        RoomNetworkManager.shared.inviteFriendListRequest(roomId, input) { [weak self] error, model in
            if let error = error {
                print("DEBUG: 초대 가능한 친구 목록 조회 에러 - \(error.localizedDescription)")
            }
            // 언래핑
            guard let modelList = model else { return }
            // FriendsModel로 변경
            let userList = modelList.map {
                FriendsModel(friendId: $0.friendId, id: $0.id, friendName: $0.friendName, file: $0.file, relationship: $0.relationship ?? 99)
            }
            // accept
            self?.userList.accept(userList)
        }
    }
    
    // 친구 리스트 조회
    func requestFriendList() {
        guard let userId = userId else { return }
        profileNetwork.getUserFriendList(userId: userId, lastPage: 0) { [weak self] response in
            guard let response = response, response.code == "J013" else {
                return
            }
            self?.userList.accept(response.friendInfoList)
            print(response.friendInfoList)
        }
    }
}

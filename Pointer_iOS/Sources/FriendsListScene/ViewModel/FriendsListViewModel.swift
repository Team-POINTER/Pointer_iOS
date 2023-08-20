//
//  FriendsListViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/13.
//

import UIKit
import RxSwift
import RxCocoa

// #1-8 responseCode
enum InviteFriendResultType: String, CaseIterable {
    case sucess = "J008"
    case roomMemberNotExist = "J001"
    case roomCreateOverLimit = "J005"
}

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
    let dismiss = BehaviorRelay<InviteFriendResultType?>(value: nil)
    
    private lazy var profileNetwork = ProfileNetworkManager()
    
    private var roomId: Int?
    private var userId: Int?
    private var lastPage: Int = 0
    private var inviteFriendIdList: [Int] = []
    
    //MARK: - Rx
    struct Input {
        let searchTextFieldEditEvent: Observable<String>
        let collectionViewItemSelected: Observable<IndexPath>
        let collectionViewModelSelected: Observable<FriendsModel>
        let confirmButtonTappedEvent: Observable<Void>
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
                self.inviteFriendsListRequest(keyword: text, lastPage: self.lastPage)
            }
            .disposed(by: disposeBag)
        
        selectedUser
            .subscribe { [weak self] users in
                guard let self = self,
                      let users = users.element else { return }
                self.inviteFriendIdList = users.map { $0.friendId }
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
        
        input.confirmButtonTappedEvent
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                
                let model = InviteFriendRequestModel(roomId: self.roomId ?? 0, userFriendIdList: self.inviteFriendIdList)
                self.inviteFriendRequest(model)
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
    func inviteFriendsListRequest(keyword: String, lastPage: Int) {
        guard let roomId = roomId else { return }
        RoomNetworkManager.shared.inviteFriendListRequest(roomId, keyword, lastPage)
            .subscribe(onNext: { [weak self] model in
                // FriendsModel로 변경
                let userList = model.map {
                    FriendsModel(friendId: $0.friendId, id: $0.id, friendName: $0.friendName, file: $0.file, relationship: 3)
                }
                // accept
                self?.userList.accept(userList)
            },
            onError: { error in
                print("초대 가능한 친구 목록 조회 - error = \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
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
    
    // 룸 초대
    private func inviteFriendRequest(_ input: InviteFriendRequestModel) {
        RoomNetworkManager.shared.invteFriendRequest(input) { [weak self] (error, model) in
            if let error = error {
                print("DEBUG: 룸 초대 에러 - \(error.localizedDescription)")
            }
            
            if let model = model {
                if model.code == InviteFriendResultType.sucess.rawValue {
                    self?.dismiss.accept(.sucess)
                } else if model.code == InviteFriendResultType.roomMemberNotExist.rawValue {
                    self?.dismiss.accept(.roomMemberNotExist)
                } else if model.code == InviteFriendResultType.roomCreateOverLimit.rawValue {
                    self?.dismiss.accept(.roomCreateOverLimit)
                } else {
                    self?.dismiss.accept(.none)
                }
            }
        }
    }
}

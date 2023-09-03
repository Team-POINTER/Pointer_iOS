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
    var targetUserName: String?
    
    let userList = BehaviorRelay<[FriendsModel]>(value: [])
    let nextViewController = BehaviorRelay<UIViewController?>(value: nil)
    let dismiss = PublishRelay<String>()
    let inviteLink = PublishRelay<String>()
    let searchTextFieldEditEvent = BehaviorRelay<String>(value: "")
    
    // 컬렉션 뷰 스크롤 밑에 닿았을 시
    let reFetchRoomInvitedFriendList = BehaviorRelay<Void?>(value: nil)
    let reFetchProfileInvitedFriendList = BehaviorRelay<Void?>(value: nil)
    
    private lazy var profileNetwork = ProfileNetworkManager()
    
    private var roomId: Int?
    private var userId: Int?
    private var lastArrayCount: Int?
    private var lastIndex: Bool = false
    private var nextPage: Int?
    private var searchText = ""
    private var inviteFriendIdList: [Int] = []
    
    //MARK: - Rx
    struct Input {
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
        
        self.searchTextFieldEditEvent
            .subscribe { [weak self] text in
                guard let self = self,
                      let text = text.element else { return }
                // 검색어 입력에 따라 keyword 넣어서 리스트 다시 호출
                self.searchText = text
                self.inviteFriendsListRequest(keyword: text)
                self.requestFriendList(keyword: text)
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
        
        // 셀을 선택했을 때
        input.collectionViewModelSelected
            .subscribe { [weak self] item in
                guard let self = self,
                      let item = item.element else { return }
                
                switch self.listType {
                case .normal:
                    let userId = item.friendId
                    let viewModel = ProfileViewModel(userId: userId)
                    let vc = ProfileViewController(viewModel: viewModel)
                    self.nextViewController.accept(vc)
                case .select:
                    self.processSelectedUser(selectedUser: item)
                    print(self.selectedUser.value.count)
                }
            }
            .disposed(by: disposeBag)
        
        input.confirmButtonTappedEvent
            .subscribe { [weak self] _ in
                guard let self = self,
                      let roomId = self.roomId else { return }
                
                let model = InviteFriendRequestModel(roomId: roomId, userFriendIdList: self.inviteFriendIdList)
                self.inviteFriendRequest(model)
            }
            .disposed(by: disposeBag)
        
        reFetchRoomInvitedFriendList
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                
                if self.lastIndex {
                    print("마지막 인덱스입니다.")
                } else {
                    self.reFetchInviteFriendsListRequest(keyword: self.searchText, lastPage: self.nextPage)
                }
            }
            .disposed(by: disposeBag)
        
        reFetchProfileInvitedFriendList
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                
                if self.lastIndex {
                    print("마지막 인덱스입니다.")
                } else {
                    self.reFetchRequestFriendList(keyword: self.searchText, lastPage: self.nextPage)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
    //MARK: - LifeCycle
    init(listType: ListType, roomId: Int? = nil, userId: Int? = nil) {
        self.listType = listType
        self.roomId = roomId
        self.userId = userId
    }
    
    // User가 선택된 상태인지 체크하는 메소드
    func detectSelectedUser(_ selectedUser: FriendsModel) -> Bool {
        var isSelectedUser = false
        for user in self.selectedUser.value {
            if user.friendId == selectedUser.friendId {
                isSelectedUser = true
                break
            }
        }
        return isSelectedUser
    }
    
    // User Select 이벤트가 들어오면 실행하는 함수
    func processSelectedUser(selectedUser: FriendsModel) {
        // 현재 선택한 유저들의 배열
        var currentSelectedUser = self.selectedUser.value
        // 이미 선택한 유저인지 체크
        let isUserSelected = detectSelectedUser(selectedUser)
        
        switch isUserSelected {
        // 이미 선택한 유저라면 - Selected 배열에서 지우기
        case true:
            currentSelectedUser.enumerated().forEach { index, user in
                if selectedUser.friendId == user.friendId {
                    currentSelectedUser.remove(at: index)
                    self.selectedUser.accept(currentSelectedUser)
                }
            }
        // 선택 안한 유저라면 - Selceted 배열에 추가
        case false:
            currentSelectedUser.append(selectedUser)
            self.selectedUser.accept(currentSelectedUser)
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
    
    func didFriendRelationChanged() {
        guard let lastArrayCount = lastArrayCount else { return }
        var resultArray = self.userList.value
        let removeStartIndex = resultArray.count - lastArrayCount
        resultArray.removeSubrange(removeStartIndex...resultArray.count - 1)
        
        if listType == .normal {
            guard let userId = userId else { return }
            
            profileNetwork.getUserFriendList(userId: userId, lastPage: self.nextPage ?? 0, keyword: self.searchText) { [weak self] response in
                guard let response = response, response.code == "J013",
                      let self = self else { return }
                print("새로 삭제후 ")
                resultArray.append(contentsOf: response.friendInfoList)
                self.userList.accept(resultArray)
            }
        }
    }
    
//MARK: - API
    // 초대 가능한 친구 목록 조회
    func inviteFriendsListRequest(keyword: String) {
        guard let roomId = roomId else { return }
        RoomNetworkManager.shared.inviteFriendListRequest(roomId: roomId, keyword: keyword, lastPage: 0) { [weak self] (error, model) in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let model = model {
                // FriendsModel로 변경
                let userList = model.friendList.map {
                    FriendsModel(friendId: $0.friendId,
                                 id: $0.id,
                                 friendName: $0.friendName,
                                 file: $0.file,
                                 relationship: 3,
                                 status: $0.status)
                }
                
                self.userList.accept(userList)
                self.nextPage = model.currentPage + 1
                self.lastArrayCount = model.friendList.count
            }
        }
    }
    
    func reFetchInviteFriendsListRequest(keyword: String, lastPage: Int?) {
        guard let roomId = roomId else { return }
        RoomNetworkManager.shared.inviteFriendListRequest(roomId: roomId, keyword: keyword, lastPage: lastPage ?? 1) { [weak self] (error, model) in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let model = model {
                if model.friendList.isEmpty {
                    self.lastIndex = true
                } else {
                    // FriendsModel로 변경
                    let userList = model.friendList.map {
                        FriendsModel(friendId: $0.friendId,
                                     id: $0.id,
                                     friendName: $0.friendName,
                                     file: $0.file,
                                     relationship: 3,
                                     status: $0.status)
                    }

                    var userListModel = self.userList.value
                    userListModel.append(contentsOf: userList)
                    self.userList.accept(userListModel)

                    self.nextPage = model.currentPage + 1
                    self.lastArrayCount = model.friendList.count
                }
            }
        }
    }
    
    // 친구 리스트 조회
    func requestFriendList(keyword: String) {
        guard let userId = userId else { return }
        profileNetwork.getUserFriendList(userId: userId, lastPage: 0, keyword: keyword) { [weak self] response in
            guard let response = response, response.code == "J013",
                  let self = self else { return }
            
            self.userList.accept(response.friendInfoList)
            self.nextPage = response.currentPage + 1
            self.lastArrayCount = response.friendInfoList.count
        }
    }
    
    func reFetchRequestFriendList(keyword: String, lastPage: Int?) {
        guard let userId = userId else { return }
        profileNetwork.getUserFriendList(userId: userId, lastPage: lastPage ?? 1, keyword: keyword) { [weak self] response in
            guard let response = response, response.code == "J013",
                  let self = self else { return }
            
            if response.friendInfoList.isEmpty {
                self.lastIndex = true
            } else {
                var userListModel = self.userList.value
                userListModel.append(contentsOf: response.friendInfoList)
                self.userList.accept(userListModel)
                self.nextPage = response.currentPage + 1
                self.lastArrayCount = response.friendInfoList.count
            }
        }
    }
    
    // 룸 초대
    private func inviteFriendRequest(_ input: InviteFriendRequestModel) {
        RoomNetworkManager.shared.invteFriendRequest(input) { [weak self] (error, model) in
            if let error = error {
                print("DEBUG: 룸 초대 에러 - \(error.localizedDescription)")
            }
            
            if let model = model {
                self?.dismiss.accept(model.message)
            }
        }
    }
    
    // 룸 초대 (링크)
    func inviteFriendWithLinkRequest() {
        guard let roomId = self.roomId else { return }
        
        RoomNetworkManager.shared.inviteFriendWithLinkRequest(roomId) { [weak self] (error, link) in
            if let error = error {
                print("DEBUG: 룸 초대 에러 - \(error.localizedDescription)")
            }
            
            if let inviteLink = link {
                self?.inviteLink.accept(inviteLink)
            }
        }
    }
}

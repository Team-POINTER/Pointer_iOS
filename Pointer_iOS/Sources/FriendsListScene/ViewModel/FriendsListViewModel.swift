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
    
    private lazy var profileNetwork = ProfileNetworkManager()
    
    private var roomId: Int?
    private var userId: Int?
    private var lastPage: Int = 0
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
                print(text)
                
                // 검색어 입력에 따라 keyword 넣어서 리스트 다시 호출
                self.inviteFriendsListRequest(keyword: text, lastPage: self.lastPage)
                self.requestFriendList(keyword: text, lastPage: self.lastPage)
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
        
        // 첫 데이터 로드
        requestFriendList(keyword: "", lastPage: lastPage)
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
    
//MARK: - API
    // 초대 가능한 친구 목록 조회
    func inviteFriendsListRequest(keyword: String, lastPage: Int) {
        guard let roomId = roomId else { return }
        RoomNetworkManager.shared.inviteFriendListRequest(roomId, keyword, lastPage)
            .subscribe(onNext: { [weak self] model in
                // FriendsModel로 변경
                let userList = model.map {
                    FriendsModel(friendId: $0.friendId, id: $0.id, friendName: $0.friendName, file: $0.file, relationship: 3, status: $0.status)
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
    func requestFriendList(keyword: String, lastPage: Int) {
        guard let userId = userId else { return }
        profileNetwork.getUserFriendList(userId: userId, lastPage: 0, keyword: keyword) { [weak self] response in
            guard let response = response, response.code == "J013" else {
                return
            }
            self?.userList.accept(response.friendInfoList)
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

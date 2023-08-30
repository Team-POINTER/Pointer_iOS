//
//  ProfileViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import YPImagePicker
import RxSwift
import RxRelay
import RxCocoa

protocol ProfileDelegate: AnyObject {
    func profileChanged()
}

class ProfileViewModel: ViewModelType {
    //MARK: - In/Out
    struct Input {
        // 액션 버튼
        let editMyProfile: Observable<UITapGestureRecognizer>
        let friendActionButtonTapped: Observable<UITapGestureRecognizer>
        let messageButtonTapped: Observable<UITapGestureRecognizer>
        let moreFriendLabelTapped: Observable<UITapGestureRecognizer>
        // collectionView
        let friendsItemSelected: Observable<IndexPath>
        let friendsModelSelected: Observable<FriendsModel>
    }
    
    struct Output {
        
    }
    
    //MARK: - Properties
    weak var delegate: ProfileDelegate?
    let disposeBag = DisposeBag()
    let userId: Int
    let cellItemSpacing = CGFloat(20)
    let horizonItemCount: Int = 5
    let profileNetwork = ProfileNetworkManager()
    lazy var friendNetwork = FriendNetworkManager()
    
    let profile = BehaviorRelay<ProfileModel?>(value: nil)
    let nextViewController = BehaviorRelay<UIViewController?>(value: nil)
    let showAlertView = PublishRelay<PointerAlert>()
    
    let friendsArray = BehaviorRelay<[FriendsModel]>(value: [])
    let friendsCount = BehaviorRelay<Int>(value: 0)
    
    // 네비게이션 바 버튼
    let preferenceButtonTapped = PublishRelay<()>()
    let otherMenuActionButtonTapped = PublishRelay<()>()
    
    var isMyProfile: Bool {
        return userId == TokenManager.getIntUserId()
    }
    
    lazy var userNameToEdit = ""
    lazy var userIdToEdit: String? = ""
    
    //MARK: - Computed Properties
    var userIdText: String {
        return "@\(profile.value?.results?.id ?? "")"
    }
    
    var userName: String? {
        return "\(profile.value?.results?.userName ?? "오류")"
    }
    
    var relationShip: Relationship {
        guard let relationship = profile.value?.results?.relationship else { return .none }
        return Relationship(rawValue: relationship) ?? .none
    }
    
    //MARK: - LifeCycle
    init(userId: Int) {
        self.userId = userId
    }
    
    //MARK: - RxTransform
    func transform(input: Input) -> Output {
        let output = Output()
        // 프로필 편집 버튼 Tapped
        input.editMyProfile
            .when(.recognized)
            .subscribe { [weak self] _ in
                guard let self = self,
                      let profile = self.profile.value else { return }
                let editViewModel = EditProfileViewModel(profile: profile)
                let editVc = ProfileEditViewController(viewModel: editViewModel)
                self.nextViewController.accept(editVc)
            }
            .disposed(by: disposeBag)
        
        // friendActionButton
        input.friendActionButtonTapped
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let alert = PointerAlert.getActionAlert(
                    title: self.relationShip.alertTitle,
                    message: self.relationShip.getAlertMessage(targetName: self.userName,
                                                               targetId: self.userIdText),
                    actionTitle: self.relationShip.alertActionTitle) { _ in
                        self.requestFriendAction()
                    }
                
                self.showAlertView.accept(alert)
            })
            .disposed(by: disposeBag)
        
        // 메시지 버튼 클릭
        input.messageButtonTapped
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { _ in
                Util.showToast("채팅 기능 준비중입니다", position: .center)
            })
            .disposed(by: disposeBag)
        
        // 더보기 텍스트 클릭 (친구 리스트)
        input.moreFriendLabelTapped
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] _ in
                guard let self = self,
                      self.friendsArray.value.count > 0 else { return }
                let viewModel = FriendsListViewModel(listType: .normal, roomId: nil, userId: self.userId)
                viewModel.targetUserName = self.userName
                let vc = FriendsListViewController(viewModel: viewModel)
                self.nextViewController.accept(vc)
            })
            .disposed(by: disposeBag)
        
        // 유저 프로필 탭 액션 바인딩 -> nextViewController
        Observable
            .zip(input.friendsItemSelected,
                 input.friendsModelSelected)
            .subscribe { [weak self] indexPath, user in
                let profileViewModel = ProfileViewModel(userId: user.friendId)
                let userProfileVc = ProfileViewController(viewModel: profileViewModel)
                profileViewModel.delegate = self
                self?.nextViewController.accept(userProfileVc)
            }
            .disposed(by: disposeBag)
        
        // 네비게이션바 메뉴 탭 이벤트 바인딩
        preferenceButtonTapped
            .bind { [weak self] _ in
                let preferenceVc = PreferenceController()
                self?.nextViewController.accept(preferenceVc)
            }
            .disposed(by: disposeBag)
        
        otherMenuActionButtonTapped
            .bind { [weak self] _ in
                guard let self = self else { return }
                let sheet = self.getOtherMenuActionSheet()
                self.showAlertView.accept(sheet)
            }
            .disposed(by: disposeBag)
        
        
        return output
    }
    
    // 친구할 사람 찾기 뷰 클릭시
    func pushToSearchFriendView() {
        let viewModel = SearchViewModel()
        let searchVc = SearchController(viewModel: viewModel)
        searchVc.viewWillShowIndex = 1
        nextViewController.accept(searchVc)
    }
    
    //MARK: - Call API
    // 프로필 정보 요청
    func requestUserProfile() {
        // 자기 자신이라면 내 프로필, 아니라면 상대 프로필 요청
        profileNetwork.requestProfileData(isMyProfile: isMyProfile, userId: userId) { [weak self] profile in
            self?.profile.accept(profile)
        }
    }
    
    func requestFriendAction() {
        guard let router = relationShip.router else { return }
        friendNetwork.requestFriendAction(userId, router: router) { [weak self] isSuccess in
            guard let self = self else { return }
            if isSuccess {
                self.requestUserProfile()
                self.requestUserFriendsList()
                self.delegate?.profileChanged()
            } else {
                let alert = PointerAlert.getSimpleAlert(title: "오류", message: "통신중에 오류가 발생했습니다🥲 다시 시도해주세요.")
                self.showAlertView.accept(alert)
            }
        }
    }
    
    // 친구 리스트 조회
    // ToDo - 페이지네이션 -30명 이상일 때
    func requestUserFriendsList() {
        print("🔥요청하는 User Id : \(userId)")
        profileNetwork.getUserFriendList(userId: userId, lastPage: 0) { [weak self] result in
            guard let result = result else { return }
            self?.friendsCount.accept(result.total)
            self?.friendsArray.accept(result.friendInfoList)
        }
    }
    
    // 친구 차단 API 호출
    private func requestBlockFriend() {
        IndicatorManager.shared.show()
        friendNetwork.requestBlockFriend(targetId: userId) { [weak self] isSuccessed in
            IndicatorManager.shared.hide()
            if isSuccessed {
                self?.requestUserProfile()
            } else {
                self?.showAlertView.accept(PointerAlert.getErrorAlert())
            }
        }
    }
    
    //MARK: - Functions
    // Cell의 사이즈를 계산해서 return합니다.
    func getCellSize() -> CGSize {
        let width = (Device.width - (cellItemSpacing * CGFloat(horizonItemCount))) / 5
        return CGSize(width: width + 5, height: width + 30)
    }
    
    //MARK: - 유저 메뉴 버튼 이벤트(신고/차단)
    // 메뉴 버튼 클릭
    private func getOtherMenuActionSheet() -> PointerAlert {
        // 신고하기 버튼
        let reportAction = PointerAlertActionConfig(title: "신고하기", textColor: .pointerRed) { [weak self] _ in
            self?.reportButtonTapped()
        }
        
        // 차단하기 버튼
        let blockAction = PointerAlertActionConfig(title: "사용자 차단하기", textColor: .black) { [weak self] _ in
            // 한번 더 물어보기
            let alert = PointerAlert.getActionAlert(title: "친구 차단", message: "\(self?.userName ?? "")님을 정말로 차단하시겠어요?", actionTitle: "차단") { _ in
                self?.requestBlockFriend()
            }
            self?.showAlertView.accept(alert)
        }
        
        // 시트
        let sheet = PointerAlert(alertType: .actionSheet, configs: [reportAction, blockAction], title: "'\(userName ?? "")'님")
        return sheet
    }
    
    private func reportButtonTapped() {
        // 이곳에 신고 기능을 입력하세요
    }
}

extension ProfileViewModel: ProfileDelegate {
    func profileChanged() {
        if let delegate = self.delegate {
            delegate.profileChanged()
        }
        self.requestUserProfile()
        self.requestUserFriendsList()
    }
}

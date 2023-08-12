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

class ProfileViewModel: ViewModelType {
    //MARK: - In/Out
    struct Input {
        let editMyProfile: Observable<UITapGestureRecognizer>
        let friendActionButtonTapped: Observable<UITapGestureRecognizer>
        let messageButtonTapped: Observable<UITapGestureRecognizer>
        // collectionView
        let friendsItemSelected: Observable<IndexPath>
        let friendsModelSelected: Observable<FriendsModel>
    }
    
    struct Output {
        
    }
    
    //MARK: - Properties
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
                self.requestFriendAction()
            })
            .disposed(by: disposeBag)
        
        // 메시지 버튼 클릭
        input.messageButtonTapped
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { _ in
                print("메시지 버튼 클릭")
            })
            .disposed(by: disposeBag)
        
        // 유저 프로필 탭 액션 바인딩 -> nextViewController
        Observable
            .zip(input.friendsItemSelected,
                 input.friendsModelSelected)
            .subscribe { [weak self] indexPath, user in
                let profileViewModel = ProfileViewModel(userId: user.userId)
                let userProfileVc = ProfileViewController(viewModel: profileViewModel)
                self?.nextViewController.accept(userProfileVc)
            }
            .disposed(by: disposeBag)
        
        return output
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
        friendNetwork.requestFriendAction(userId, router: relationShip.router) { [weak self] isSuccess in
            guard let self = self else { return }
            if isSuccess {
                self.requestUserProfile()
                self.requestUserFriendsList()
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
            self?.friendsArray.accept(result.userList)
        }
    }
    
    //MARK: - Functions


    // Cell의 사이즈를 계산해서 return합니다.
    func getCellSize() -> CGSize {
        let width = (Device.width - (cellItemSpacing * CGFloat(horizonItemCount))) / 5
        return CGSize(width: width + 5, height: width + 30)
    }
}

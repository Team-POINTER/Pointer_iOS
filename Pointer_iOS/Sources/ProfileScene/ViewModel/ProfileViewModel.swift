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
        let cancelBlockAction: Observable<Void>
        let friendRequestCancelAction: Observable<Void>
        let confirmRequestFriendAction: Observable<Void>
        let friendCancelAction: Observable<Void>
        let friendRequestAction: Observable<Void>
    }
    
    struct Output {
        
    }
    
    //MARK: - Properties
    weak var delegate: ProfileInfoViewDelegate?
    let disposeBag = DisposeBag()
    var isMyProfile = false
    let userId: Int
    let cellItemSpacing = CGFloat(20)
    let horizonItemCount: Int = 5
    let network = ProfileNetworkManager()
    
    let profile = BehaviorRelay<ProfileModel?>(value: nil)
    let nextViewController = BehaviorRelay<UIViewController?>(value: nil)
    let userSelectedProfileImage = BehaviorRelay<UIImage?>(value: nil)
    let userSelectedBackgroundImage = BehaviorRelay<UIImage?>(value: nil)
    
    lazy var userNameToEdit = ""
    lazy var userIdToEdit: String? = ""
    
    //MARK: - Computed Properties
    var userIdText: String {
        return "@\(profile.value?.results?.id ?? "")"
    }
    
    var userName: String? {
        return "\(profile.value?.results?.userName ?? "오류")"
    }
    
    var friendsCountText: String {
        return "친구 5명"
    }
    
    var numberOfFriendsCellCount: Int {
        return 10
    }
    
    //MARK: - LifeCycle
    init(userId: Int) {
        self.userId = userId
    }
    
    //MARK: - RxTransform
    func transform(input: Input) -> Output {
        
        input.editMyProfile
            .when(.recognized)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                print("👉")
                let editVc = ProfileEditViewController(viewModel: self)
                self.nextViewController.accept(editVc)
            }
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    //MARK: - Functions
    func getImagePickerConfig() -> YPImagePickerConfiguration {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.showsPhotoFilters = false
        config.wordings.libraryTitle = "앨범"
        config.wordings.cameraTitle = "카메라"
        config.wordings.next = "확인"
        config.colors.tintColor = .pointerRed
        return config
    }
    
    //MARK: - Call API
    func requestUserProfile() {
        // 자기 자신이라면 내 프로필, 아니라면 상대 프로필 요청
        if TokenManager.getIntUserId() == self.userId {
            network.getMyProfile { [weak self] profile in
                self?.isMyProfile = true
                self?.profile.accept(profile)
            }
        } else {
            network.getUserProfile(userId: userId) { [weak self] profile in
                self?.profile.accept(profile)
            }
        }
    }
    
    func requestSaveEditProfile() {
        
    }
    
    func getCellSize() -> CGSize {
        let width = (Device.width - (cellItemSpacing * CGFloat(horizonItemCount))) / 5
        return CGSize(width: width + 5, height: width + 30)
    }
}

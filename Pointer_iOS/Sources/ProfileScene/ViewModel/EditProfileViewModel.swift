//
//  EditProfileViewModel.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/05.
//

import UIKit
import YPImagePicker
import RxSwift
import RxRelay
import RxCocoa

class EditProfileViewModel: ViewModelType {
    //MARK: - In/Out
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    //MARK: - Properties
    let network = ProfileNetworkManager()
    let disposeBag = DisposeBag()
    
    // profile 모델
    let originalProfile: ProfileModel
    var profile: ProfileModel
    var isProfileChanged = false
    
    // edit 버튼 클릭 이벤트
    let editBackgroundImageTapped = PublishSubject<Void>()
    let editUserIdViewTapped = PublishSubject<Void>()
    
    // 유저가 선택한 이미지를 담기
    let userSelectedProfileImage = BehaviorRelay<UIImage?>(value: nil)
    let userSelectedBackgroundImage = BehaviorRelay<UIImage?>(value: nil)
    
    // 기본 이미지로 변경했는지 체크
    var isUserProfileDefault = false
    var isUserBackgroundDefault = false
    var isUserIdChanged = false
    
    // 변경한 값이 있는지 연산 프로퍼티
    var isProfileEditied: Bool {
        return profile.results?.userName != originalProfile.results?.userName || isUserProfileDefault || isUserBackgroundDefault || isUserIdChanged || userSelectedProfileImage.value != nil || userSelectedBackgroundImage.value != nil
    }
    
    init(profile: ProfileModel) {
        self.originalProfile = profile
        self.profile = profile
    }
    
    //MARK: - RxSwift transform
    func transform(input: Input) -> Output {
        return Output()
    }
    
    //MARK: - Methods
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
    
    //MARK: - API
    func requestSaveEditProfile(completion: @escaping () -> Void) {
        // 0. 변경할 유저 이름 언래핑
        guard let userName = profile.results?.userName else { return }
        
        // 1. userName이 original과 달라졌거나,
        //    userProfile을 Default로 변경했거나,
        //    userBackground를 Default로 변경했다면
        // -> 네트워크에 저장 요청
        if isProfileEditied {
            IndicatorManager.shared.show()
            network.uploadImages(profileImage: userSelectedProfileImage.value,
                                 backgroundImage: userSelectedBackgroundImage.value,
                                 name: userName,
                                 profileImageDefaultChange: isUserProfileDefault,
                                 backgroundImageDefaultChange: isUserBackgroundDefault) { isSuccess in
                IndicatorManager.shared.hide()
                if isSuccess {
                    completion()
                } else {
                    print("이미지 업로드 실패 - 에러처리 필요")
                }
            }
        } else {
            // 2. 변경사항이 없다면 뒤로가서 새로고침만
            completion()
        }
    }
}

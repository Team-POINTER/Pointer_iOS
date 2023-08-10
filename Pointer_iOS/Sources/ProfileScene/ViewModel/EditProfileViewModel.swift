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
    var profile: ProfileModel
    
    let editBackgroundImageTapped = PublishSubject<Void>()
    let editUserIdViewTapped = PublishSubject<Void>()
    
    let userSelectedProfileImage = BehaviorRelay<UIImage?>(value: nil)
    let userSelectedBackgroundImage = BehaviorRelay<UIImage?>(value: nil)
    
    init(profile: ProfileModel) {
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
        print("🔥눌림: \(profile.results?.userName)")
        guard let userName = profile.results?.userName else { return }
        print("🔥가드문 통과: \(userName)")
        network.uploadImages(profileImage: userSelectedProfileImage.value,
                             backgroundImage: userSelectedBackgroundImage.value,
                             name: userName,
                             profileImageDefaultChange: false,
                             backgroundImageDefaultChange: false) { isSuccess in
            
            if isSuccess {
                completion()
            } else {
                print("이미지 업로드 실패 - 에러처리 필요")
            }
        }
    }
}

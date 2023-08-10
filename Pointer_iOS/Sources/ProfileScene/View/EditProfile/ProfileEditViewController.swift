//
//  ProfileEditViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/07.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import SnapKit
import YPImagePicker

class ProfileEditViewController: ProfileParentViewController {
    // Photo Edit Type
    enum PhotoEditType: String {
        case profile = "프로필 사진 편집"
        case background = "배경 이미지 편집"
    }
    //MARK: - Properties
    let viewModel: ProfileViewModel
    let editProfileInfoView: EditProfileInfoView
    let cameraImageView: UIImageView = {
        let cameraImageView = UIImageView()
        cameraImageView.image = UIImage(named: "camera")
        cameraImageView.contentMode = .scaleAspectFill
        return cameraImageView
    }()
    
    let myProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfile")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 106 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var editableProfileImageView: UIView = {
        let view = UIView()
        
        view.addSubview(myProfileImageView)
        view.addSubview(cameraImageView)
        
        myProfileImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        cameraImageView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        return view
    }()
    
    //MARK: - Selector
    @objc private func saveButtonTapped() {
        viewModel.requestSaveEditProfile()
    }
    
    //MARK: - Lifecycle
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        self.editProfileInfoView = EditProfileInfoView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        editProfileInfoView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarPointerBackButton()
        setupNavigationBar()
        setupUI()
        bind()
        hideKeyboardWhenTappedAround()
    }
    
    //MARK: - Functions
    func bind() {
        cameraImageView.rx.tapGesture().when(.recognized)
            .bind { [weak self] _ in
                self?.modifyImageButtonTapped(type: .profile)
            }
            .disposed(by: disposeBag)
        
        // 유저가 선택한 프로필 뷰에 바인딩
        viewModel.userSelectedProfileImage
            .bind { [weak self] image in
                guard let image = image else { return }
                self?.myProfileImageView.image = image
            }
            .disposed(by: disposeBag)
        
        // 유저가 선택한 배경 이미지 뷰에 바인딩
        viewModel.userSelectedBackgroundImage
            .bind { [weak self] image in
                guard let image = image else { return }
                self?.backgroundImageView.image = image
            }
            .disposed(by: disposeBag)
    }
    
    // 네비게이션바 셋업
    func setupNavigationBar() {
        let saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .red
        navigationItem.rightBarButtonItem = saveButton
    }
    
    // 프로필 이미지 변경 뷰 Sheet
    func modifyImageButtonTapped(type: PhotoEditType) {
        let selectConfig = PointerAlertActionConfig(title: "앨범에서 사진/동영상 선택", textColor: .pointerRed) { [weak self] _ in
            self?.presentImagePicker(type: type)
        }
        let setDefaultConfig = PointerAlertActionConfig(title: "기본 이미지로 변경", textColor: .pointerRed) { _ in }
        let actionSheet = PointerAlert(alertType: .actionSheet, configs: [selectConfig, setDefaultConfig], title: type.rawValue)
        self.present(actionSheet, animated: true)
    }
    
    // 이미지 Picker
    func presentImagePicker(type: PhotoEditType) {
        let picker = YPImagePicker(configuration: viewModel.getImagePickerConfig())
        picker.didFinishPicking { [weak self, unowned picker] items, _ in
            if let photo = items.singlePhoto {
                if type == .profile {
                    self?.viewModel.userSelectedProfileImage.accept(photo.image)
                } else {
                    self?.viewModel.userSelectedBackgroundImage.accept(photo.image)
                }
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.tabBarController!.present(picker, animated: true, completion: nil)
    }
    
    // 이미지 셋업
    override func setupUI() {
        super.profileImageView = editableProfileImageView
        super.profileInfoView = editProfileInfoView
        super.backgroundImageView.backgroundColor = .systemIndigo
        super.setupUI()
        
        guard let profile = viewModel.profile.value else { return }
        configureProfileImage(model: profile)
    }
    
    // Configure
    private func configureProfileImage(model: ProfileModel) {
        guard let urls = model.results?.imageUrls,
              let profileUrl = URL(string: urls.profileImageUrl),
              let backgroundUrl = URL(string: urls.backgroundImageUrl) else { return }
        myProfileImageView.kf.indicatorType = .activity
        myProfileImageView.kf.setImage(with: profileUrl)
        
        backgroundImageView.kf.indicatorType = .activity
        backgroundImageView.kf.setImage(with: backgroundUrl)
    }
}

//MARK: - EditProfileInfoViewDelegate
// 수정 뷰 각 컴포넌트들의 이벤트
extension ProfileEditViewController: EditProfileInfoViewDelegate {
    func editBackgroundButtonTapped() {
        modifyImageButtonTapped(type: .background)
    }
    
    func editUserIDViewTapped() {
        let vc = EditUserIDViewController(viewModel: viewModel)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileEditViewController: EditUserIdDelegate {
    func editUserIdSuccessed() {
        viewModel.requestUserProfile()
    }
}

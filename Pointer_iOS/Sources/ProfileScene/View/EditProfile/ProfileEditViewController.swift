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

class ProfileEditViewController: ProfileParentViewController {
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
        bind(viewModel: viewModel)
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
            .bind { _ in
                print("프로필 이미지 변경 뷰 눌림")
            }.disposed(by: disposeBag)
    }
    
    func setupNavigationBar() {
        let saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .red
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func setupUI() {
        super.profileImageView = editableProfileImageView
        super.profileInfoView = editProfileInfoView
        super.backgroundImageView.backgroundColor = .systemIndigo
        super.setupUI()
        
        guard let profile = viewModel.profile.value else { return }
        configureProfileImage(model: profile)
    }
    
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

extension ProfileEditViewController: EditProfileInfoViewDelegate {
    func editBackgroundButtonTapped() {
        print(#function)
    }
    
    func editUserIDViewTapped() {
        let vc = EditUserIDViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}

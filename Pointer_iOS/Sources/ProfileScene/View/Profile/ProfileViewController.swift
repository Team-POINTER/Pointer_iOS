//
//  ProfileViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import SnapKit
import RxSwift

class ProfileViewController: ProfileParentViewController {
    //MARK: - Properties
    let viewModel: ProfileViewModel
    
    lazy var profileImageViewChild: UIView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfile")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 106 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var profileInfoViewChild: ProfileInfoView = {
        let view = ProfileInfoView(viewModel: viewModel)
        return view
    }()
    
    //MARK: - Lifecycle
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupNavigation(viewModel: viewModel)
        viewModel.requestUserProfile()
        viewModel.requestUserFriendsList()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK: - Bind
    func bind() {
        // 프로필 정보 바인딩
        viewModel.profile
            .bind { [weak self] model in
                guard let model = model else { return }
                self?.setProfileImage(model: model)
            }
            .disposed(by: disposeBag)
        
        // 다음 뷰
        viewModel.nextViewController
            .throttle(.microseconds(500), scheduler: MainScheduler.instance)
            .bind { [weak self] nextVc in
                guard let vc = nextVc else { return }
                // EditViewController라면 delegate 주입
                if let editVc = vc as? ProfileEditViewController {
                    editVc.delegate = self
                }
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        // AlertView 바인딩
        viewModel.showAlertView
            .bind { [weak self] alert in
                self?.navigationController?.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
        
        backgroundImageView.rx.tapGesture()
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] _ in
                let photoView = PointerFullScreenPhotoView(image: self?.backgroundImageView.image)
                self?.present(photoView, animated: true)
            })
            .disposed(by: disposeBag)
        
        profileImageView.rx.tapGesture()
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] _ in
                guard let self = self,
                      let profileImageView = self.profileImageView as? UIImageView else { return }
                let photoView = PointerFullScreenPhotoView(image: profileImageView.image)
                self.present(photoView, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    
    //MARK: - Functions
    private func setupNavigationBar() {
        // rootViewController가 아닌경우에만 backbutton활성화
        if navigationController?.viewControllers.first != self {
            super.setNavigationBarPointerBackButton()
        }
    }
    
    override func setupUI() {
        super.profileImageView = profileImageViewChild
        super.profileInfoView = profileInfoViewChild
        super.backgroundImageView.backgroundColor = .clear
        super.setupUI()
    }
}

extension ProfileViewController: ProfileEditDelegate {
    func profileEditSuccessed() {
        print("프로필 변경 성공")
        viewModel.requestUserProfile()
    }
}

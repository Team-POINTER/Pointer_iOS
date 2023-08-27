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
    
    private lazy var profileImageViewChild: UIView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfile")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 106 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var profileInfoViewChild: ProfileInfoView = {
        let view = ProfileInfoView(viewModel: viewModel)
        return view
    }()
    
    private lazy var preferenceButton = UIBarButtonItem.getPointerBarButton(withIconimage: UIImage(systemName: "gearshape"), target: self, handler: #selector(preferneceButtonTapped))
    private lazy var moreActionButton = UIBarButtonItem.getPointerBarButton(withIconimage: UIImage(systemName: "text.justify"), target: self, handler: #selector(moreActionButtonTapped))
    
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
        setupNavigationBarBackButton()
        setupNavigationRightButton()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        viewModel.requestUserProfile()
        viewModel.requestUserFriendsList()
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
    // 설정 버튼 눌렸을 때
    @objc private func preferneceButtonTapped() {
        viewModel.preferenceButtonTapped.accept(())
    }
    
    // 상대 프로필 액션 버튼 클릭 이벤트
    @objc private func moreActionButtonTapped() {
        viewModel.otherMenuActionButtonTapped.accept(())
    }
    
    //MARK: - SetupNavigation Controller
    private func setupNavigationBarBackButton() {
        if navigationController?.viewControllers.first != self {
            super.setNavigationBarPointerBackButton()
        }
    }
    
    private func setupNavigationRightButton() {
        if viewModel.isMyProfile {
            // 내 프로필 - 설정버튼 설정
            self.navigationItem.rightBarButtonItem = preferenceButton
        } else {
            // 상대 프로필 - 옵션버튼 설정
            self.navigationItem.rightBarButtonItem = moreActionButton
        }
    }
    
    //MARK: - Methods
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

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
    //더미!
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
        setupNavigation(viewModel: viewModel)
        bind()
        viewModel.requestUserProfile()
    }
    
    //MARK: - Bind
    func bind() {
        viewModel.profile
            .bind { [weak self] model in
                guard let model = model else { return }
                self?.setProfileImage(model: model)
            }
            .disposed(by: disposeBag)
        
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
    }
    
    //MARK: - Selector
    
    //MARK: - Functions
    private func setupNavigationBar() {
        
    }
    
    override func setupUI() {
        super.profileImageView = profileImageViewChild
        super.profileInfoView = profileInfoViewChild
        super.backgroundImageView.backgroundColor = .systemIndigo
        super.setupUI()
    }
}

extension ProfileViewController: ProfileEditDelegate {
    func profileEditSuccessed() {
        print("프로필 변경 성공")
        viewModel.requestUserProfile()
    }
}

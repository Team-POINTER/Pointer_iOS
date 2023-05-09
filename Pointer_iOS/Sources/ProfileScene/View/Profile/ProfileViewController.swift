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
    let viewModel = ProfileViewModel(user: User(memberType: .myAccount, userName: "김지수", userID: "jisu.kim", friendsCount: 10))
    
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
        view.delegate = self
        return view
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

extension ProfileViewController: ProfileInfoViewDelegate {
    func editMyProfileButtonTapped() {
        print("DEBUG - 프로필 수정 버튼 눌림")
        let vc = ProfileEditViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func friendsActionButtonTapped() {
        print("DEBUG - 친구 액션 버튼 눌림")
    }
    
    func messageButtonTapped() {
        print("DEBUG - 메시지 버튼 눌림")
    }
}
//
//  ProfileViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import SnapKit
import RxSwift

class ProfileViewController: BaseViewController {
    //MARK: - Properties
    //더미!
    let viewModel = ProfileViewModel(user: User(memberType: .notFollowing, userName: "김지수", userID: "jisu.kim", friendsCount: 10))
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.rgb(red: 26, green: 26, blue: 28)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var profileInfoView: ProfileInfoView = {
        let view = ProfileInfoView(viewModel: viewModel)
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
    
    private func setupUI() {
        view.addSubview(profileInfoView)
        profileInfoView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(360 - Device.tabBarHeight)
            profileInfoView.setGradient(color1: .pointerGradientStart, color2: .pointerGradientEnd)
        }
        
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(profileInfoView.snp.top)
        }
        
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(106)
            $0.bottom.equalTo(backgroundImageView.snp.bottom).inset(-106 / 2)
            $0.leading.equalToSuperview().inset(20)
            profileImageView.layer.cornerRadius = 106 / 2
            profileImageView.clipsToBounds = true
        }
    }
}

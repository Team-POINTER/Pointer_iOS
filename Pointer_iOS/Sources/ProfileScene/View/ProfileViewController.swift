//
//  ProfileViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import SnapKit
import RxSwift

class ProfileViewController: UIViewController {
    //MARK: - Properties
    let viewModel = ProfileViewModel()
    
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
        let dummyUser = User(isSelf: true, userName: "김지수", userID: "jisu.kim", friendsCount: 10)
        let view = ProfileInfoView(user: dummyUser, viewModel: viewModel)
        return view
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    //MARK: - Selector
    
    //MARK: - Functions
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(profileInfoView)
        view.addSubview(profileImageView)
        
        backgroundImageView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            let height = (view.frame.height - view.safeAreaInsets.top) / 2
            $0.height.equalTo(height)
        }
        
        profileInfoView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.top.equalTo(backgroundImageView.snp.bottom)
            profileInfoView.setGradient(color1: .pointerGradientStart, color2: .pointerGradientEnd)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(106)
            $0.bottom.equalTo(backgroundImageView.snp.bottom).inset(-106 / 2)
            $0.leading.equalToSuperview().inset(20)
            profileImageView.layer.cornerRadius = 106 / 2
            profileImageView.clipsToBounds = true
        }
    }
}

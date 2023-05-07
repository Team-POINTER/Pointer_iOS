//
//  ProfileEditViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/07.
//

import UIKit
import SnapKit

class ProfileEditViewController: ProfileParentViewController {
    //MARK: - Properties
    let viewModel: ProfileViewModel
    let editProfileInfoView: EditProfileInfoView
    let editableProfileImageView: UIView = {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfile")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 106 / 2
        imageView.clipsToBounds = true
        
        let cameraImageView = UIImageView()
        cameraImageView.image = UIImage(named: "camera")
        cameraImageView.contentMode = .scaleAspectFill
        
        view.addSubview(imageView)
        view.addSubview(cameraImageView)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        cameraImageView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        return view
    }()
    
    //MARK: - Lifecycle
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        self.editProfileInfoView = EditProfileInfoView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - Functions
    override func setupUI() {
        super.profileImageView = editableProfileImageView
        super.profileInfoView = editProfileInfoView
        super.setupUI()
    }
}

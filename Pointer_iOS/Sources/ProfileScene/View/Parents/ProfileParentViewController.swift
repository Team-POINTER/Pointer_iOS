//
//  ProfileViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import Kingfisher
import SnapKit
import RxSwift

class ProfileParentViewController: BaseViewController {
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.rgb(red: 26, green: 26, blue: 28)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private var _profileImageView = UIView()
    var profileImageView: UIView {
        get {
            return _profileImageView
        }
        set {
            return _profileImageView = newValue
        }
    }
    
    private var _profileInfoView = UIView()
    var profileInfoView: UIView {
        get {
            return _profileInfoView
        } set {
            return _profileInfoView = newValue
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - Bind
    //MARK: - Bind
    func bind(viewModel: ProfileViewModel) {
        viewModel.profile
            .bind { [weak self] model in
                guard let model = model else { return }
                self?.setProfileImage(model: model)
            }
            .disposed(by: disposeBag)
    }
    
    func setProfileImage(model: ProfileModel) {
        guard let profileImageView = profileImageView as? UIImageView,
              let urls = model.results?.imageUrls,
              let profileUrl = URL(string: urls.profileImageUrl),
              let backgroundUrl = URL(string: urls.backgroundImageUrl) else { return }
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: profileUrl)
        
        backgroundImageView.kf.indicatorType = .activity
        backgroundImageView.kf.setImage(with: backgroundUrl)
    }
    
    //MARK: - Selector
    
    //MARK: - Functions
    func setupUI() {
        view.addSubview(_profileInfoView)
        _profileInfoView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(360 - Device.tabBarHeight)
        }
        
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(_profileInfoView.snp.top)
        }
        
        view.addSubview(_profileImageView)
        _profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(106)
            $0.bottom.equalTo(backgroundImageView.snp.bottom).inset(-106 / 2)
            $0.leading.equalToSuperview().inset(20)
        }
    }
}

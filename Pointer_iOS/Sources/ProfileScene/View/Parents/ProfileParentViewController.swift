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
    
    func setProfileImage(model: ProfileModel) {
        guard let profileImageView = profileImageView as? UIImageView,
              let urls = model.results?.imageUrls,
              let profileUrl = URL(string: urls.profileImageUrl),
              let backgroundUrl = URL(string: urls.backgroundImageUrl) else { return }
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: profileUrl) { result in
//            switch result {
//            case .success(let value):
//                if let data = value.image.pngData() {
//                    let sizeInBytes = data.count
//                    let sizeInKilobytes = Double(sizeInBytes) / 1024.0
////                    print("🔥프사 용량: \(sizeInKilobytes) KB")
//                }
//            case .failure(let error):
//                print(error)
//            }
        }
        
        backgroundImageView.kf.indicatorType = .activity
        backgroundImageView.kf.setImage(with: backgroundUrl) { result in
//            switch result {
//            case .success(let value):
//                if let data = value.image.pngData() {
//                    let sizeInBytes = data.count
//                    let sizeInKilobytes = Double(sizeInBytes) / 1024.0
////                    print("🔥배경사진 용량: \(sizeInKilobytes) KB")
//                }
//            case .failure(let error):
//                print(error)
//            }
        }
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
    
    //MARK: - SetupNavigation Controller
    func setupNavigation(viewModel: ProfileViewModel) {
        if viewModel.isMyProfile {
            let preferenceButton = UIBarButtonItem.getPointerBarButton(withIconimage: UIImage(systemName: "gearshape"), target: self, handler: #selector(preferneceButtonTapped))
            self.navigationItem.rightBarButtonItem = preferenceButton
        }
    }
    
    // 설정 버튼 눌렸을 때
    @objc func preferneceButtonTapped() {
        let preferenceVc = PreferenceController()
        self.navigationController?.pushViewController(preferenceVc, animated: true)
    }
}

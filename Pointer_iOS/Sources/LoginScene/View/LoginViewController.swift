
//
//  LoginViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/24.
//

import UIKit
import SnapKit
import KakaoSDKAuth
import KakaoSDKUser

class LoginViewController: BaseViewController {

    lazy var loginViewModel: LoginViewModel = { LoginViewModel() }()
    
    
    private let mainImage: UIImageView = {
        $0.image = UIImage(named: "pointer_login")
        return $0
    }(UIImageView())
    
    private let startLabel: UILabel = {
        $0.text = "SNS계정으로 간편하게 시작하기"
        $0.font = UIFont.notoSansRegular(size: 13)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let stackView: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    private let kakaoButton: UIButton = {
        $0.setImage(UIImage(named: "kakao_login"), for: .normal)
        return $0
    }(UIButton())
    
    private let appleButton: UIButton = {
        $0.setImage(UIImage(named: "apple_login"), for: .normal)
        return $0
    }(UIButton())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setUIConstraints()
        
        kakaoButton.addTarget(self, action: #selector(kakaoButtonTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
    }
    

    func setUI() {
        view.addSubview(mainImage)
        view.addSubview(startLabel)
        view.addSubview(stackView)
        stackView.addArrangedSubview(kakaoButton)
        stackView.addArrangedSubview(appleButton)
    }
    
    func setUIConstraints() {
        mainImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(Device.height * 0.25)
            make.width.equalTo(140)
            make.height.equalTo(150)
        }
    
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(Device.height * 0.18)
        }
        
        startLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).inset(-11)
            make.centerX.equalToSuperview()
        }
        
        kakaoButton.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        appleButton.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    @objc func kakaoButtonTapped() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            // 카카오톡 로그인. api 호출 결과를 클로저로 전달.
            loginViewModel.loginWithApp() { loginInfo in
                if loginInfo == "서비스이용동의 이동" {
                    self.navigationController?.pushViewController(TermsViewController(), animated: true)
                } else {
                    self.navigationController?.pushViewController(BaseTabBarController(), animated: true)
                }
            }
        } else {
            // 만약, 카카오톡이 깔려있지 않을 경우에는 웹 브라우저로 카카오 로그인함.
            loginViewModel.loginWithWeb() { loginInfo in
                if loginInfo == "서비스이용동의 이동" {
                    self.navigationController?.pushViewController(TermsViewController(), animated: true)
                } else {
                    self.navigationController?.pushViewController(BaseTabBarController(), animated: true)
                }
            }
        }
    }
    
    
    @objc func appleButtonTapped() {
        
    }
    
}


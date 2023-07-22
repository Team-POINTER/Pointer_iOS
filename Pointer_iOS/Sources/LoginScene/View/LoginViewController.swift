
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
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController {
    
    var disposeBag = DisposeBag()
    lazy var loginViewModel: LoginViewModel = { LoginViewModel() }()
    
//MARK: - RX
    func bindViewModel() {
        let input = LoginViewModel.Input(kakaoLoginTap: kakaoButton.rx.tap.asObservable(),
                                         appleLoginTap: appleButton.rx.tap.asObservable())
        let output = loginViewModel.transform(input: input)
        
        output.nextViewController
            .bind(onNext: { [weak self] vc in
                guard let self = self,
                      let parentVc = self.presentingViewController else { return }
                self.dismiss(animated: false) {
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    parentVc.present(nav, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    
        output.dissMiss
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    
//MARK: - UIComponents
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
    
    
    

//MARK: - set UI
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
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setUIConstraints()
        bindViewModel()
    }
    
}


//
//  CreateUserIDViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/01.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CreateUserIDViewController: BaseViewController {

    var disposeBag = DisposeBag()
    let createUserIdViewModel: CreateUserIDViewModel
    
    init(viewModel: CreateUserIDViewModel, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.createUserIdViewModel = viewModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - RX
    func bindViewModel() {
        let input = CreateUserIDViewModel.Input(idTextFieldEditEvent: inputUserIDTextfeild.rx.text.orEmpty.asObservable(), idDoubleCheckButtonTapEvent: idDoubleCheckButton.rx.tap.asObservable(), nextButtonTapEvent: nextButton.rx.tap.asObservable())
        let output = createUserIdViewModel.transform(input: input)
        
        output.idTextFieldLimitedString
            .bind(to: self.inputUserIDTextfeild.rx.text)
            .disposed(by: disposeBag)
        
        output.idTextFieldCountString
            .bind(to: self.checkCountValidLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.idTextFieldValidString
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.checkValueValidLabel.text = "중복 확인해주세요."
                    self?.checkValueValidLabel.textColor = UIColor.inactiveGray
                } else {
                    self?.checkValueValidLabel.text = "형식에 어긋난 아이디입니다."
                    self?.checkValueValidLabel.textColor = UIColor.pointerRed
                }
            }).disposed(by: disposeBag)
        
    }
    
    
//MARK: - Properties
    let inputUserIDTextfeild: UITextField = {
        $0.attributedPlaceholder = NSAttributedString(
            string: "입력하세요.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.inactiveGray])
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 14)
        $0.backgroundColor = .clear
        $0.textColor = UIColor.white
        return $0
    }(UITextField())
    
    let textfieldBottomLine: UIView = {
        $0.backgroundColor = UIColor.inactiveGray
        return $0
    }(UIView())
    
    let idDoubleCheckButton: UIButton = {
        $0.setTitle("중복확인", for: .normal)
        $0.setTitleColor(UIColor.pointerRed, for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 14)
        return $0
    }(UIButton())
    
    var checkValueValidLabel: UILabel = {
        $0.text = "사용가능한 아이디입니다."
        $0.font = UIFont.notoSansRegular(size: 12)
        $0.textColor = UIColor.inactiveGray
        return $0
    }(UILabel())
    
    var checkCountValidLabel: UILabel = {
        $0.text = "0/30"
        $0.font = UIFont.notoSansRegular(size: 12)
        $0.textColor = UIColor.inactiveGray
        return $0
    }(UILabel())
    
    let noticeValidLabel: UILabel = {
        $0.text = "・ 영문 숫자 및 특수문자 .과 _만 사용 가능합니다. \n・ 최대 30자까지 가능하며 띄어쓰기를 허용하지 않습니다."
        $0.font = UIFont.notoSansRegular(size: 12.5)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var nextButton: UIButton = {
        $0.backgroundColor = UIColor.rgb(red: 87, green: 90, blue: 107)
        $0.titleLabel?.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.titleLabel?.textColor = UIColor.white
        $0.layer.cornerRadius = 16
        $0.setTitle("확인", for: .normal)
        $0.isEnabled = false
        return $0
    }(UIButton())
    
//MARK: - set UI
    func setUI() {
        view.addSubview(inputUserIDTextfeild)
        view.addSubview(textfieldBottomLine)
        view.addSubview(idDoubleCheckButton)
        view.addSubview(checkValueValidLabel)
        view.addSubview(checkCountValidLabel)
        view.addSubview(noticeValidLabel)
        view.addSubview(nextButton)
    }
    
    func setUIConstraints() {
        idDoubleCheckButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalToSuperview().inset(17)
        }
        inputUserIDTextfeild.snp.makeConstraints { make in
            make.centerY.equalTo(idDoubleCheckButton.snp.centerY)
            make.leading.equalToSuperview().inset(17)
            make.trailing.equalToSuperview().inset(85)
        }
        textfieldBottomLine.snp.makeConstraints { make in
            make.top.equalTo(idDoubleCheckButton.snp.bottom).inset(-7)
            make.leading.trailing.equalToSuperview().inset(15.5)
            make.height.equalTo(1)
        }
        checkValueValidLabel.snp.makeConstraints { make in
            make.top.equalTo(textfieldBottomLine.snp.bottom).inset(-7)
            make.leading.equalToSuperview().inset(17)
        }
        checkCountValidLabel.snp.makeConstraints { make in
            make.top.equalTo(textfieldBottomLine.snp.bottom).inset(-7)
            make.trailing.equalToSuperview().inset(17)
        }
        noticeValidLabel.snp.makeConstraints { make in
            make.top.equalTo(checkValueValidLabel.snp.bottom).inset(-25)
            make.leading.equalToSuperview().inset(17)
        }
        nextButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(33)
            make.leading.trailing.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(65)
        }
    }
    
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setUIConstraints()
        bindViewModel()
        configureBar()
    }

//MARK: - NavigationBar
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
        self.title = "사용자 아이디 생성"
    }
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}

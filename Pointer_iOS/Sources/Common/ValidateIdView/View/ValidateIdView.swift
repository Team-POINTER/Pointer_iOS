//
//  ValidateIdView.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ValidateIdView: UIView {
    //MARK: - Properties
    public let viewModel: ValidateIdViewModel
    private let disposeBag = DisposeBag()
    
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
        $0.isEnabled = false
        $0.titleLabel?.font = UIFont.notoSansBold(size: 14)
        return $0
    }(UIButton())
    
    var checkValueValidLabel: UILabel = {
        $0.font = UIFont.notoSansRegular(size: 11)
        $0.textColor = UIColor.inactiveGray
        return $0
    }(UILabel())
    
    var checkCountValidLabel: UILabel = {
        $0.text = "0/30"
        $0.font = UIFont.notoSansRegular(size: 11)
        $0.textColor = UIColor.inactiveGray
        return $0
    }(UILabel())
    
    let noticeValidLabel: UILabel = {
        $0.text = "・ 영문 숫자 및 특수문자 .과 _만 사용 가능합니다. \n・ 최대 30자까지 가능하며 띄어쓰기를 허용하지 않습니다."
        $0.font = UIFont.notoSansRegular(size: 11)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    //MARK: - Lifecycle
    init(_ viewModel: ValidateIdViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    func bind() {
        let input = ValidateIdViewModel.Input(
            idTextFieldEditEvent: inputUserIDTextfeild.rx.text.orEmpty.asObservable(),
            idDoubleCheckButtonTapEvent: idDoubleCheckButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        viewModel.userEnteredId
            .bind(to: inputUserIDTextfeild.rx.text)
            .disposed(by: disposeBag)
        
        output.idTextFieldCountString
            .bind(to: checkCountValidLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.idTextFieldValidString
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.idDoubleCheckButton.isEnabled = true
                    self?.idDoubleCheckButton.setTitleColor(UIColor.pointerRed, for: .normal)
                } else {
                    self?.idDoubleCheckButton.isEnabled = false
                    self?.idDoubleCheckButton.setTitleColor(UIColor.inactiveGray, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        output.validateIdResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] style in
                self?.checkValueValidLabel.text = style.description
                self?.checkValueValidLabel.textColor = style.fontColor
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Methods
    private func setupUI() {
        self.addSubview(inputUserIDTextfeild)
        self.addSubview(textfieldBottomLine)
        self.addSubview(idDoubleCheckButton)
        self.addSubview(checkValueValidLabel)
        self.addSubview(checkCountValidLabel)
        self.addSubview(noticeValidLabel)
        
        idDoubleCheckButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(35)
            make.trailing.equalToSuperview().inset(17)
            make.height.equalTo(20)
            make.width.equalTo(55)
        }
        
        inputUserIDTextfeild.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(17)
            make.trailing.equalTo(idDoubleCheckButton.snp.leading).inset(-5)
            make.top.bottom.equalTo(idDoubleCheckButton)
        }
        
        textfieldBottomLine.snp.makeConstraints { make in
            make.top.equalTo(idDoubleCheckButton.snp.bottom).inset(-9)
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
            make.top.equalTo(textfieldBottomLine.snp.bottom).inset(-45)
            make.leading.equalToSuperview().inset(17)
        }
    }
}

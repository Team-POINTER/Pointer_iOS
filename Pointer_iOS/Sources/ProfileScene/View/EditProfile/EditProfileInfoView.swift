//
//  EditProfileInfoView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/07.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SnapKit

protocol EditProfileInfoViewDelegate: AnyObject {
    func editBackgroundButtonTapped()
    func editUserIDViewTapped()
}

class EditProfileInfoView: ProfileInfoParentView {
    //MARK: - Properties
    var delegate: EditProfileInfoViewDelegate?
    let editViewModel: EditProfileViewModel
    
    lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.text = editViewModel.profile.results?.userName
        tf.font = .notoSans(font: .notoSansKrMedium, size: 25)
        tf.textColor = .inactiveGray
        tf.textAlignment = .center
//        tf.delegate = self
        return tf
    }()
    
    let nameTextFieldUnderLine: UIView = {
        let line = UIView()
        line.backgroundColor = .inactiveGray
        return line
    }()
    
    lazy var nameTextFieldView: UIView = {
        let containerView = UIView()
        containerView.addSubview(nameTextField)
        containerView.addSubview(nameTextFieldUnderLine)
        
        nameTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nameTextFieldUnderLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
        return containerView
    }()
    
    let userIDGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "사용자 아이디"
        label.textAlignment = .center
        label.font = .notoSansRegular(size: 18)
        label.textColor = .white
        return label
    }()
    
    lazy var userIdLabel: UILabel = {
        let userIDLabel = UILabel()
        userIDLabel.textColor = .inactiveGray
        userIDLabel.font = .notoSansRegular(size: 18)
        userIDLabel.textAlignment = .center
        userIDLabel.text = editViewModel.profile.results?.id
        return userIDLabel
    }()
    
    lazy var userIDView: UIView = {
        let container = UIView()

        let line = UIView()
        line.backgroundColor = .inactiveGray
        
        container.addSubview(self.userIdLabel)
        container.addSubview(line)
        
        self.userIdLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        line.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
        return container
    }()
    
    let editBackgroundImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .pointerRed
        let attribute = NSAttributedString(string: "배경 이미지 변경",
                                           attributes: [NSAttributedString.Key.font: UIFont.notoSansBold(size: 13)])
        button.setAttributedTitle(attribute, for: .normal)
        button.setTitle("배경 이미지 변경", for: .normal)
        button.tintColor = .white
        return button
    }()
    
    //MARK: - Lifecycle
    init(editViewModel: EditProfileViewModel, delegate: ProfileInfoViewDelegate? = nil) {
        self.editViewModel = editViewModel
        super.init(viewModel: nil, delegate: delegate)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    func bind() {
        
        editBackgroundImageButton.rx.tap
            .subscribe { [weak self] _ in
                self?.editViewModel.editBackgroundImageTapped.onNext(())
            }
            .disposed(by: disposeBag)
        
        userIDView.rx.tapGesture().when(.recognized)
            .bind { [weak self] _ in
                self?.editViewModel.editUserIdViewTapped.onNext(())
            }.disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidBegin)
            .asObservable()
            .bind { [weak self] _ in
                self?.nameTextField.textColor = .white
                self?.nameTextFieldUnderLine.backgroundColor = .white
            }.disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .bind { [weak self] _ in
                self?.nameTextField.textColor = .inactiveGray
                self?.nameTextFieldUnderLine.backgroundColor = .inactiveGray
            }.disposed(by: disposeBag)
        
        nameTextField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] text in
                self?.editViewModel.profile.results?.userName = text
            })
            .disposed(by: disposeBag)
    }
    
    override func setupUI() {
        super.nameView = nameTextFieldView
        super.setupUI()
        nameTextFieldView.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        addSubview(editBackgroundImageButton)
        editBackgroundImageButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(nameTextFieldView.snp.bottom)
            $0.width.equalTo(116)
            $0.height.equalTo(35)
            editBackgroundImageButton.layer.cornerRadius = 35 / 2
            editBackgroundImageButton.clipsToBounds = true
        }
        
        let stack = UIStackView(arrangedSubviews: [userIDGuideLabel, userIDView])
        stack.axis = .horizontal
        stack.alignment = .fill
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(nameTextFieldView.snp.bottom).inset(-28)
            $0.height.equalTo(60)
        }
        
        userIDGuideLabel.snp.makeConstraints {
            $0.width.equalTo(self.snp.width).multipliedBy(0.45)
        }
    }
    
    private func configure() {
        
    }
}

////MARK: - UITextFieldDelegate
//extension EditProfileInfoView: UITextFieldDelegate {
//
//    // 텍스트 필드 수정이 끝나면 값 저장
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        guard let text = textField.text else { return }
//        self.viewModel.userNameToEdit = text
//    }
//}

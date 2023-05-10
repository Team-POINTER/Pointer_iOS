//
//  EditUserIDViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/09.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class EditUserIDViewController: UIViewController {
    enum IDPolicy {
        static let policy: [String] = [
            "영문, 숫자 및 특수문자 .과 _만 사용 가능합니다.",
            "최대 30자까지 가능하며 띄어쓰기를 허용하지 않습니다."
        ]
    }
    
    //MARK: - Properties
    var disposeBag = DisposeBag()
    let viewModel: ProfileViewModel
    
    let userIDTextField: UITextField = {
        let tf = UITextField()
        return tf
    }()
    
    let textFieldUnderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .inactiveGray
        return view
    }()
    
    let checkValidateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("중복확인", for: .normal)
        button.tintColor = .pointerRed
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.contentHorizontalAlignment = .trailing
        return button
    }()
    
    let checkValidateResultLabel: UILabel = {
        let label = UILabel()
        label.text = "사용가능한 아이디입니다"
        label.textColor = .inactiveGray
        label.font = .notoSansRegular(size: 11)
        return label
    }()
    
    let checkIDCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .inactiveGray
        label.font = .notoSansRegular(size: 11)
        label.text = "10/30"
        return label
    }()
    
    let idPolicyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .inactiveGray
        label.font = .notoSansRegular(size: 11)
        label.numberOfLines = 0
        return label
    }()
    
    //MARK: - Lifecycle
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        configure()
        bind()
    }
    
    //MARK: - Selector
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        
    }
    
    //MARK: - Bind
    private func bind() {
        checkValidateButton.rx.tap
            .subscribe { _ in
                print("중복확인 버튼이 눌림")
            }.disposed(by: disposeBag)
    }
    
    //MARK: - Functions
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem.getPointerBackBarButton(target: self, handler: #selector(backButtonTapped))
        let saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .red
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = saveButton
        
        navigationItem.title = "사용자 아이디 수정"
        
        //
        //        navigationController?.navigationBar.topItem?.titleView?.tintColor = .blue
        //
        //        navigationController?.toolbar.tintColor = .black
        //        navigationItem.titleView?.tintColor = .black
        //        navigationController?.navigationBar.tintColor = .black
        //        navigationController?.navigationBar.topItem?.titleView?.tintColor = .black
        //        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        //        // ??
    }
    
    private func setupUI() {
        view.backgroundColor = .black

        let textFieldStack = UIStackView(arrangedSubviews: [userIDTextField, checkValidateButton])
        textFieldStack.axis = .horizontal
        textFieldStack.spacing = 10
        textFieldStack.alignment = .fill
        
        view.addSubview(textFieldStack)
        textFieldStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.height.equalTo(30)
        }
        
        view.addSubview(textFieldUnderLine)
        textFieldUnderLine.snp.makeConstraints {
            $0.top.equalTo(textFieldStack.snp.bottom).inset(-7)
            $0.leading.equalTo(textFieldStack.snp.leading)
            $0.trailing.equalTo(textFieldStack.snp.trailing)
            $0.height.equalTo(2)
        }
        
        let validateStack = UIStackView(arrangedSubviews: [checkValidateResultLabel, checkIDCountLabel])
        validateStack.axis = .horizontal
        validateStack.alignment = .fill
        
        view.addSubview(validateStack)
        validateStack.snp.makeConstraints {
            $0.leading.equalTo(textFieldStack.snp.leading)
            $0.trailing.equalTo(textFieldStack.snp.trailing)
            $0.top.equalTo(textFieldUnderLine.snp.bottom).inset(-5)
        }
        
        view.addSubview(idPolicyLabel)
        idPolicyLabel.snp.makeConstraints {
            $0.leading.equalTo(textFieldStack.snp.leading)
            $0.trailing.equalTo(textFieldStack.snp.trailing)
            $0.top.equalTo(validateStack.snp.bottom).inset(-30)
        }
    }
    
    private func configure() {
        userIDTextField.text = viewModel.user.userID
        idPolicyLabel.text = getPolicyString()
    }
    
    private func getPolicyString() -> String {
        let policyString = IDPolicy.policy.map { "•  \($0)\n" }.joined()
        return policyString
    }
}

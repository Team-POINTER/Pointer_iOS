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

protocol EditUserIdDelegate: AnyObject {
    func editUserIdSuccessed(id: String)
}

class EditUserIDViewController: BaseViewController {
    //MARK: - Properties
    weak var delegate: EditUserIdDelegate?
    var disposeBag = DisposeBag()
    let viewModel: EditUserIDViewModel
    lazy var validateIdView = ValidateIdView(ValidateIdViewModel(existUserId: viewModel.userIdToEdit))
    // 저장하기 버튼
    lazy var saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonTapped))
    
    
    //MARK: - Lifecycle
    init(profile: ProfileModel) {
        self.viewModel = EditUserIDViewModel(user: profile)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
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
        let input = EditUserIDViewModel.Input(
            saveButtonTapEvent: saveButton.rx.tap.asObservable(),
            validateIdViewModel: validateIdView.viewModel)
        let output = viewModel.transform(input: input)
        
        output.isSaveButtonActive
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // ID 변경에 성공했을 경우
        output.isSuccessSaveUserId
            .bind { [weak self] isSucessed, userId in
                guard let id = userId else { return }
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.editUserIdSuccessed(id: id)
            }
            .disposed(by: disposeBag)
        
        // 에러 Alert
        output.errorAlert
            .bind { [weak self] alert in
                self?.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Functions
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem.getPointerBackBarButton(target: self, handler: #selector(backButtonTapped))
        saveButton.tintColor = .red
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = saveButton
        
        navigationItem.title = "사용자 아이디 수정"
    }
    
    private func setupUI() {
        view.addSubview(validateIdView)
        validateIdView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

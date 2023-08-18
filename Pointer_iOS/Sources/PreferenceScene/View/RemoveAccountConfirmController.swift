//
//  RemoveAccountConfirmController.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/19.
//

import UIKit

class RemoveAccountConfirmController: BaseViewController {
    //MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansBold(size: 25)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .pointerRed
        label.text = "탈퇴가 완료되었습니다"
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        let text = NSMutableAttributedString(string: "확인", attributes: [.font: UIFont.notoSans(font: .notoSansKrMedium, size: 18), .foregroundColor: UIColor.white])
        button.setAttributedTitle(text, for: .normal)
        button.backgroundColor = .pointerRed
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    //MARK: - Methods
    @objc private func actionButtonTapped() {
        sceneDelegate?.appCoordinator?.logout()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(view.frame.height * 0.3)
        }
        
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(60)
        }
        
        actionButton.layer.cornerRadius = 13
        actionButton.clipsToBounds = true
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = "탈퇴하기"
        self.navigationItem.leftBarButtonItem = nil
    }
}

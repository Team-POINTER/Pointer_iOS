//
//  RemoveAccountController.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/19.
//

import UIKit
import SnapKit
import RxSwift
import RxGesture

class RemoveAccountController: BaseViewController {
    //MARK: - Properties
    private let disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansBold(size: 25)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.984, green: 0.989, blue: 1, alpha: 1)
        label.text = "포인터 님의 친구들이\n당신을 기다리고 있어요"
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.806, green: 0.816, blue: 0.879, alpha: 1)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.36
        paragraphStyle.alignment = .center
        label.attributedText = NSMutableAttributedString(string: "계정을 삭제하면 현재까지 활동한 \n모든 정보가 삭제됩니다.", attributes: [.paragraphStyle: paragraphStyle])
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        let text = NSMutableAttributedString(string: "탈퇴하기", attributes: [.font: UIFont.notoSans(font: .notoSansKrMedium, size: 18), .foregroundColor: UIColor(red: 0.984, green: 0.989, blue: 1, alpha: 1)])
        button.setAttributedTitle(text, for: .normal)
        button.backgroundColor = UIColor(red: 0.341, green: 0.353, blue: 0.42, alpha: 1)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let text = NSMutableAttributedString(string: "취소", attributes: [.font: UIFont.notoSans(font: .notoSansKrMedium, size: 18), .foregroundColor: UIColor.white])
        button.setAttributedTitle(text, for: .normal)
        button.backgroundColor = .pointerRed
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bind()
    }
    
    // 버튼들의 액션
    private func bind() {
        // 탈퇴
        actionButton.rx.tapGesture()
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] _ in
                // 확인 뷰로 푸시
                AuthNetworkManager.shared.resignUserAccount { isSuccessed in
                    if isSuccessed {
                        let vc = RemoveAccountConfirmController()
                        self?.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let alert = PointerAlert.getErrorAlert()
                        self?.present(alert, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 취소
        cancelButton.rx.tapGesture()
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Methods
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(view.frame.height * 0.3)
        }
        
        view.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(titleLabel.snp.bottom).inset(-20)
        }
        
        let stack = UIStackView(arrangedSubviews: [actionButton, cancelButton])
        stack.axis = .horizontal
        stack.spacing = 7
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        
        stack.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(60)
        }
        
        stack.subviews.forEach { view in
            view.layer.cornerRadius = 13
            view.clipsToBounds = true
        }
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = "탈퇴하기"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissButtonTapped))
    }
    
    //MARK: - Handler
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true)
    }
}

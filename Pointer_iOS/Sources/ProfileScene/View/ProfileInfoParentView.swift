//
//  ProfileInfoView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

private let cellIdentifier = "UserFriendCell"

protocol ProfileInfoViewDelegate: AnyObject {
    func editMyProfileButtonTapped()
    func friendsActionButtonTapped()
    func messageButtonTapped()
}

class ProfileInfoParentView: UIView {
    //MARK: - Properties
    var delegate: ProfileInfoViewDelegate?
    let viewModel: ProfileViewModel
    var disposeBag = DisposeBag()
    
    let nameView = UIView()
    
    //MARK: - Lifecycle
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        bind()
        setupUI()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        
    }
    
    //MARK: - Functions
    private func setupUI() {
        
        addSubview(nameView)
        nameView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(36.7)
            $0.top.equalToSuperview().inset(67)
        }
    }
    
    private func configure() {

    }
}

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
    
    var _nameView = UIView()
    var nameView: UIView {
        get {
            return _nameView
        } set {
            return _nameView = newValue
        }
    }
    
    //MARK: - Lifecycle
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    func setupUI() {
        addSubview(_nameView)
        _nameView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(106)
            $0.top.equalToSuperview().inset(67)
        }
    }
}

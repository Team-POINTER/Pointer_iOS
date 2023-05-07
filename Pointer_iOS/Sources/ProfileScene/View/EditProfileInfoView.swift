//
//  EditProfileInfoView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/07.
//

import UIKit
import SnapKit

class EditProfileInfoView: ProfileInfoParentView {
    //MARK: - Properties
    lazy var nameTextFieldView: UIView = {
        let tf = UITextField()
        tf.text = viewModel.user.userName
        tf.font = .notoSans(font: .notoSansKrMedium, size: 25)
        tf.textColor = .white
        tf.textAlignment = .center
        
        let line = UIView()
        line.backgroundColor = .white

        let containerView = UIView()
        containerView.addSubview(tf)
        containerView.addSubview(line)
        
        tf.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        line.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        return containerView
    }()
    
    //MARK: - Lifecycle
    override init(viewModel: ProfileViewModel) {
        super.init(viewModel: viewModel)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    override func setupUI() {
        super.nameView = nameTextFieldView
        super.setupUI()
        nameTextFieldView.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalTo(100)
        }
    }
}

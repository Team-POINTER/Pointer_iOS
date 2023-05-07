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
        tf.textColor = .inactiveGray
        tf.textAlignment = .center
        
        let line = UIView()
        line.backgroundColor = .inactiveGray

        let containerView = UIView()
        containerView.addSubview(tf)
        containerView.addSubview(line)
        
        tf.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        line.snp.makeConstraints {
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
    
    lazy var userIDView: UIView = {
        let container = UIView()
        
        let userIDLabel = UILabel()
        userIDLabel.textColor = .inactiveGray
        userIDLabel.font = .notoSansRegular(size: 18)
        userIDLabel.textAlignment = .center
        userIDLabel.text = viewModel.userIdText
        
        let line = UIView()
        line.backgroundColor = .inactiveGray
        
        container.addSubview(userIDLabel)
        container.addSubview(line)
        
        userIDLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        line.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
        return container
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
        }
        
        let stack = UIStackView(arrangedSubviews: [userIDGuideLabel, userIDView])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(nameTextFieldView.snp.bottom).inset(-28)
            $0.height.equalTo(60)
        }
    }
}

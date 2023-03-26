//
//  FriendsNotiCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/26.
//

import UIKit

class FriendsNotiCell: UICollectionViewCell {
    //MARK: - Properties
    let userProfilImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "defaultProfile")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        return iv
    }()
    
    let userAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "tadeu_bonini"
        label.font = .notoSans(font: .notoSansKrMedium, size: 13)
        label.textColor = .white
        return label
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "추민서"
        label.font = .notoSansRegular(size: 11)
        label.textColor = .white
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .pointerRed
        button.setAttributedTitle(NSAttributedString(string: "친구 신청", attributes: [NSAttributedString.Key.font: UIFont.notoSans(font: .notoSansKrMedium, size: 10), NSAttributedString.Key.foregroundColor: UIColor.white]), for: .normal)
        return button
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    private func setupUI() {
        addSubview(userProfilImageView)
        userProfilImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
            userProfilImageView.layer.cornerRadius = 22
            userProfilImageView.clipsToBounds = true
        }
        
        let infoStack = UIStackView(arrangedSubviews: [userAccountLabel, userNameLabel])
        infoStack.axis = .vertical
        
        addSubview(infoStack)
        infoStack.snp.makeConstraints {
            $0.leading.equalTo(userProfilImageView.snp.trailing).inset(-11)
            $0.centerY.equalTo(userProfilImageView.snp.centerY)
        }
        
        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.trailing.equalToSuperview().inset(19)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(56)
            actionButton.layer.cornerRadius = 12
            actionButton.clipsToBounds = true
        }
    }
}

//
//  UserFriendCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import SnapKit

class UserFriendCell: UICollectionViewCell {
    //MARK: - Properties
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "personIcon")
        iv.backgroundColor = .blue
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "김지수"
        label.font = .notoSans(font: .notoSansKrMedium, size: 13)
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    private func setupUI() {
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(profileImageView.snp.width)
            profileImageView.layer.cornerRadius = 10
            profileImageView.clipsToBounds = true
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).inset(-8)
            $0.leading.trailing.equalToSuperview()
        }
    }
}

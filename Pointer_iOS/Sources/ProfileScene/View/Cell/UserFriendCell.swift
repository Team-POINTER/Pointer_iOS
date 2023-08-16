//
//  UserFriendCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import SnapKit

class UserFriendCell: UICollectionViewCell {
    //MARK: - Identifier
    static let cellIdentifier = "UserFriendCell"
    
    //MARK: - Properties
    var userData: FriendsModel? {
        didSet {
            configure()
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "defaultProfile")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .notoSans(font: .notoSansKrMedium, size: 13)
        label.textAlignment = .center
        return label
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
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(profileImageView.snp.width)
            profileImageView.layer.cornerRadius = 10
            profileImageView.clipsToBounds = true
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).inset(-5)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    // data fetch
    private func configure() {
        guard let data = userData else { return }
        nameLabel.text = data.friendName
        if let url = data.file {
            profileImageView.kf.setImage(with: URL(string: url))
        }
    }
}

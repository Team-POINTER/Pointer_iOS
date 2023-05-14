//
//  FriendsListCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/13.
//

import UIKit
import SnapKit

class FriendsListCell: UICollectionViewCell {
    //MARK: - Properties
    static let cellIdentifier = "FriendsListCell"
    
    var user: User? {
        didSet {
            configure()
        }
    }
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let userIdLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSans(font: .notoSansKrMedium, size: 13)
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSans(font: .notoSansKrRegular, size: 11)
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
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(5)
            $0.width.equalTo(profileImageView.snp.height)
            profileImageView.layer.cornerRadius = (self.frame.height - 10) / 2
            profileImageView.clipsToBounds = true
        }
        
        let stack = UIStackView(arrangedSubviews: [userIdLabel, userNameLabel])
        stack.axis = .vertical
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(profileImageView.snp.trailing).inset(-11)
        }
    }
    
    private func configure() {
        guard let user = user else { return }
        profileImageView.image = .defaultProfile
        userIdLabel.text = user.userID
        userNameLabel.text = user.userName
    }
}

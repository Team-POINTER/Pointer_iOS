//
//  FriendsNotiCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/26.
//

import UIKit
import Kingfisher
import SnapKit

class FriendsNotiCell: UICollectionViewCell {
    //MARK: - Properties
    weak var delegate: RelationshipFriendActionDelegate?
    var item: FriendAlarmList? {
        didSet {
            configure()
        }
    }
    
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
    
    private var relationshipActionView: RelationshipFriendActionView?
    
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
    }
    
    private func configure() {
        guard let item = item else { return }
        
        let profileUrl = URL(string: item.sendUserProfile.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        
        userProfilImageView.kf.indicatorType = .activity
        userProfilImageView.kf.setImage(with: profileUrl)
        
        userNameLabel.text = "\(item.sendUserId)"
        userAccountLabel.text = item.sendUserName
        
        let relationShip = Relationship(rawValue: item.relationship) ?? .none

        // reuse 된 경우
        if let view = self.relationshipActionView {
            view.removeFromSuperview()
            self.relationshipActionView = nil
        }
        // 새로 만든 경우
        let actionButtonView = RelationshipFriendActionView(userId: item.userId, relationship: relationShip, userName: item.sendUserName, userStringId: item.sendUserId)
        actionButtonView.delegate = delegate
        self.relationshipActionView = actionButtonView
        guard let view = relationshipActionView else { return }
        addSubview(view)
        view.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
    }
}

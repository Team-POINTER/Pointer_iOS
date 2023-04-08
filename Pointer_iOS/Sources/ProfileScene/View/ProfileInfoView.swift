//
//  ProfileInfoView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import UIKit
import SnapKit

struct User {
    let isSelf: Bool
    let userName: String
    let userID: String
    let friendsCount: Int
    
}

private let cellIdentifier = "UserFriendCell"

class ProfileInfoView: UIView {
    //MARK: - Properties
    let user: User
    let viewModel: ProfileViewModel
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSans(font: .notoSansKrMedium, size: 25)
        label.textColor = .white
        return label
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 179, green: 183, blue: 205)
        label.font = .notoSansRegular(size: 18)
        return label
    }()
    
    let seperator: UIView = {
        let view = UIView()
        view.backgroundColor = .rgb(red: 87, green: 90, blue: 107)
        return view
    }()
    
    let friendsCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 121, green: 125, blue: 148)
        label.font = .notoSansRegular(size: 13)
        return label
    }()
    
    let moreFriendsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "더보기"
        label.font = .notoSans(font: .notoSansKrMedium, size: 13)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = viewModel.cellItemSpacing
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemIndigo
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    //MARK: - Lifecycle
    init(user: User, viewModel: ProfileViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupCollectionView()
        setupUI()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    private func setupCollectionView() {
        collectionView.register(UserFriendCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupUI() {
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(36.7)
            $0.top.equalToSuperview().inset(67)
        }
        
        addSubview(idLabel)
        idLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
        }
        
        addSubview(seperator)
        seperator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(17.5)
            $0.top.equalTo(idLabel.snp.bottom).inset(-22)
            $0.height.equalTo(0.5)
        }
        
        addSubview(friendsCountLabel)
        friendsCountLabel.snp.makeConstraints {
            $0.leading.equalTo(seperator.snp.leading)
            $0.top.equalTo(seperator.snp.bottom).inset(-8)
        }
        
        addSubview(moreFriendsLabel)
        moreFriendsLabel.snp.makeConstraints {
            $0.trailing.equalTo(seperator.snp.trailing)
            $0.top.equalTo(seperator.snp.bottom).inset(-8)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(moreFriendsLabel.snp.bottom).inset(-12)
            $0.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func configure() {
        nameLabel.text = user.userName
        idLabel.text = "@\(user.userID)"
        friendsCountLabel.text = "친구 \(user.friendsCount)"
    }
}

extension ProfileInfoView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? UserFriendCell else { return UICollectionViewCell() }
        return cell
    }
}

extension ProfileInfoView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.getCellSize()
    }
}

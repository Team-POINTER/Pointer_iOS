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

class ProfileInfoView: ProfileInfoParentView {
    //MARK: - Properties
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSans(font: .notoSansKrMedium, size: 25)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 179, green: 183, blue: 205)
        label.font = .notoSansRegular(size: 18)
        label.textAlignment = .center
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
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    // 자기 자신일 때
    lazy var editMyProfileButton = getActionButton("프로필 편집")
    
    // 상대방 프로필일 때
    lazy var cancelBlockButton = getActionButton() // 0 - 차단 해제 버튼
    lazy var friendRequestCancelButton = getActionButton() // 1 - 친구 요청 취소 버튼
    lazy var confirmRequestFriendButton = getActionButton() // 2 - 친구 요청 수락 버튼
    lazy var friendCancelButton = getActionButton() // 3 - 친구 해제 버튼
    lazy var friendRequestButton = getActionButton() // 4 - 친구 요청 버튼
    
    lazy var messageButton = getActionButton()
//    lazy var
    
    let buttonStack: UIStackView = {
        // 버튼을 담을 StackView 생성
        let stack = UIStackView(arrangedSubviews: [])
        stack.spacing = 10
        stack.axis = .horizontal
        return stack
    }()
    
    //MARK: - Lifecycle
    override init(viewModel: ProfileViewModel, delegate: ProfileInfoViewDelegate? = nil) {
        super.init(viewModel: viewModel, delegate: delegate)
        bind()
        setupCollectionView()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        let input = ProfileViewModel.Input(
            editMyProfile: editMyProfileButton.rx.tap,
            cancelBlockAction: cancelBlockButton.rx.tap,
            friendRequestCancelAction: friendRequestCancelButton.rx.tap,
            confirmRequestFriendAction: confirmRequestFriendButton.rx.tap,
            friendCancelAction: friendCancelButton.rx.tap,
            friendRequestAction: friendRequestButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        // 모델 바인딩
        super.viewModel.profile
            .bind { [weak self] model in
                guard let model = model else { return }
                self?.configure(model: model)
                self?.configureActionButtonUI(model: model)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Functions
    private func setupCollectionView() {
        collectionView.register(UserFriendCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
    }
    
    override func setupUI() {
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(67)
            $0.width.equalTo(106)
        }
        
        addSubview(idLabel)
        idLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.width.equalTo(106)
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
        
        // 버튼 Layout
        addSubview(buttonStack)
        buttonStack.snp.makeConstraints {
            $0.trailing.equalTo(seperator.snp.trailing)
            $0.bottom.equalTo(idLabel.snp.bottom)
            $0.height.equalTo(28)
        }
    }
        
    private func configure(model: ProfileModel) {
        nameLabel.text = model.results?.userName
        idLabel.text = model.results?.id
        friendsCountLabel.text = "friend count ?"
        collectionView.reloadData()
    }
    
    // 유저 타입별 분기 처리
    private func configureActionButtonUI(model: ProfileModel) {
        
        if viewModel.isMyProfile == true {
            buttonStack.addArrangedSubview(editMyProfileButton)
            // 버튼 Corner Radius
            buttonStack.subviews.forEach {
                $0.layer.cornerRadius = 28 / 2
                $0.clipsToBounds = true
                $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
            }
            return
        }
        
        guard let relationship = model.results?.relationship,
              let friendType = Relationship(rawValue: relationship) else { return }
        
        switch friendType {
        case .block:
            buttonStack.addArrangedSubview(cancelBlockButton)
            cancelBlockButton.backgroundColor = friendType.backgroundColor
            cancelBlockButton.tintColor = friendType.tintColor
            cancelBlockButton.setAttributedTitle(friendType.attributedTitle, for: .normal)
        case .friendRequested:
            buttonStack.addArrangedSubview(friendRequestCancelButton)
            friendRequestCancelButton.backgroundColor = friendType.backgroundColor
            friendRequestCancelButton.tintColor = friendType.tintColor
            friendRequestCancelButton.setAttributedTitle(friendType.attributedTitle, for: .normal)
        case .friendRequestReceived:
            buttonStack.addArrangedSubview(confirmRequestFriendButton)
            confirmRequestFriendButton.backgroundColor = friendType.backgroundColor
            confirmRequestFriendButton.tintColor = friendType.tintColor
            confirmRequestFriendButton.setAttributedTitle(friendType.attributedTitle, for: .normal)
        case .friend:
            buttonStack.addArrangedSubview(friendCancelButton)
            friendCancelButton.backgroundColor = friendType.backgroundColor
            friendCancelButton.tintColor = friendType.tintColor
            friendCancelButton.setAttributedTitle(friendType.attributedTitle, for: .normal)
        case .friendRejected:
            buttonStack.addArrangedSubview(friendRequestButton)
            friendRequestButton.backgroundColor = friendType.backgroundColor
            friendRequestButton.tintColor = friendType.tintColor
            friendRequestButton.setAttributedTitle(friendType.attributedTitle, for: .normal)
        }
        
        buttonStack.addArrangedSubview(messageButton)

        // 버튼 Corner Radius
        buttonStack.subviews.forEach {
            $0.layer.cornerRadius = 28 / 2
            $0.clipsToBounds = true
            $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
        }
    }
    
    // 버튼 생성
    private func getActionButton(_ title: String = "읽는중") -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .black
        let string = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.notoSans(font: .notoSansKrMedium, size: 13)])
        button.setAttributedTitle(string, for: .normal)
        return button
    }
}

extension ProfileInfoView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfFriendsCellCount
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

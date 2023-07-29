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
    var delegate: ProfileInfoViewDelegate?

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
    
    lazy var editMyProfileButton = getActionButton(title: "프로필 편집")
    lazy var friendsActionButton = getActionButton(title: "읽는중")
    lazy var messageButton = getActionButton(title: "메시지")
    
    let buttonStack: UIStackView = {
        // 버튼을 담을 StackView 생성
        let stack = UIStackView(arrangedSubviews: [])
        stack.spacing = 10
        stack.axis = .horizontal
        return stack
    }()
    
    //MARK: - Lifecycle
    override init(viewModel: ProfileViewModel) {
        super.init(viewModel: viewModel)
        bind()
        setupCollectionView()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        // 프로필 편집 버튼
        editMyProfileButton.rx.tap
            .subscribe { [weak self] _ in
                self?.delegate?.editMyProfileButtonTapped()
            }.disposed(by: disposeBag)
        
        // 친구 액션 버튼
        friendsActionButton.rx.tap
            .subscribe { [weak self] _ in
                self?.delegate?.friendsActionButtonTapped()
            }.disposed(by: disposeBag)
        
        // 메시지 버튼
        messageButton.rx.tap
            .subscribe { [weak self] _ in
                self?.delegate?.messageButtonTapped()
            }.disposed(by: disposeBag)
        
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
        collectionView.dataSource = self
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
        case .none:
            buttonStack.addArrangedSubview(friendsActionButton)
            buttonStack.addArrangedSubview(messageButton)
            friendsActionButton.backgroundColor = .pointerRed
            friendsActionButton.tintColor = .white
            friendsActionButton.setAttributedTitle(getButtonTitle(title: "친구 신청"), for: .normal)
        case .friend:
            buttonStack.addArrangedSubview(friendsActionButton)
            buttonStack.addArrangedSubview(messageButton)
            friendsActionButton.backgroundColor = .rgb(red: 121, green: 125, blue: 148)
            friendsActionButton.tintColor = .white
            friendsActionButton.setAttributedTitle(getButtonTitle(title: "친구 ✓"), for: .normal)
        case .friendRequested:
            buttonStack.addArrangedSubview(friendsActionButton)
            buttonStack.addArrangedSubview(messageButton)
            friendsActionButton.backgroundColor = .rgb(red: 121, green: 125, blue: 148)
            friendsActionButton.tintColor = .white
            friendsActionButton.setAttributedTitle(getButtonTitle(title: "친구 요청됨"), for: .normal)
        }

        // 버튼 Corner Radius
        buttonStack.subviews.forEach {
            $0.layer.cornerRadius = 28 / 2
            $0.clipsToBounds = true
            $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
        }
    }
    
    // 버튼 생성
    private func getActionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .black
        button.setAttributedTitle(getButtonTitle(title: title), for: .normal)
        return button
    }
    
    // 버튼 Attributed Title
    private func getButtonTitle(title: String) -> NSAttributedString {
        let string = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.notoSans(font: .notoSansKrMedium, size: 13)])
        return string
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

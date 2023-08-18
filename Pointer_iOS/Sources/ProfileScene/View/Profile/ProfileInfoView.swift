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
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 179, green: 183, blue: 205)
        label.font = .notoSansRegular(size: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
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
        layout.minimumLineSpacing = viewModel?.cellItemSpacing ?? 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    private let emptyView = FriendListEmptyView()
    
    // 자기 자신일 때
    lazy var editMyProfileButton = getActionButton("프로필 편집")
    
    // 상대방 프로필일 때
    lazy var friendActionButton = getActionButton()
    lazy var messageButton = getActionButton("메시지")
    
    let buttonStack: UIStackView = {
        // 버튼을 담을 StackView 생성
        let stack = UIStackView(arrangedSubviews: [])
        stack.spacing = 10
        stack.axis = .horizontal
        return stack
    }()
    
    
    //MARK: - Lifecycle
    override init(viewModel: ProfileViewModel?, delegate: ProfileInfoViewDelegate? = nil) {
        super.init(viewModel: viewModel, delegate: delegate)
        setupCollectionView()
        setupEmptyView()
        bind()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        let input = ProfileViewModel.Input(
            editMyProfile: editMyProfileButton.rx.tapGesture().asObservable(),
            friendActionButtonTapped: friendActionButton.rx.tapGesture().asObservable(),
            messageButtonTapped: messageButton.rx.tapGesture().asObservable(),
            moreFriendLabelTapped: moreFriendsLabel.rx.tapGesture().asObservable(),
            friendsItemSelected: collectionView.rx.itemSelected.asObservable(),
            friendsModelSelected: collectionView.rx.modelSelected(FriendsModel.self).asObservable()
        )
        
        guard let viewModel = viewModel else { return }
        
        let output = viewModel.transform(input: input)
        
        // 모델 바인딩
        viewModel.profile
            .bind { [weak self] model in
                guard let model = model else { return }
                self?.configure(model: model)
                self?.configureActionButtonUI(model: model)
            }
            .disposed(by: disposeBag)
        
        // 친구 리스트 바인딩
        viewModel.friendsArray
            .do(onNext: { [weak self] list in
                self?.emptyView.isHidden = !list.isEmpty
            })
            .bind(to: collectionView.rx.items) { collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserFriendCell.cellIdentifier, for: IndexPath(row: indexPath, section: 0)) as? UserFriendCell else { return UICollectionViewCell() }
                cell.userData = item
                return cell
            }
            .disposed(by: disposeBag)
        
        // 친구 카운트
        viewModel.friendsCount
            .bind { [weak self] count in
                self?.friendsCountLabel.text = "\(count)명"
            }
            .disposed(by: disposeBag)
        
        // 더보기 누르기
    }
    
    //MARK: - Functions
    private func setupCollectionView() {
        collectionView.register(UserFriendCell.self, forCellWithReuseIdentifier: UserFriendCell.cellIdentifier)
        collectionView.delegate = self
    }
    
    // EmptyView 세팅
    private func setupEmptyView() {
        if viewModel?.isMyProfile == true {
            emptyView.titleText = "아직 친구를 찾지 못하셨나요?"
            emptyView.buttonText = "친구할 사람 찾기"
            emptyView.buttonAction = viewModel?.pushToSearchFriendView
        } else {
            emptyView.titleText = "친구 목록이 비어있어요"
        }
    }
    
    override func setupUI() {
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(67)
            $0.width.equalTo(Device.width * 0.4)
        }
        
        addSubview(idLabel)
        idLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.width.equalTo(Device.width * 0.4)
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
        
        addSubview(emptyView)
        emptyView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(collectionView.snp.centerY).offset(-40)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(65)
        }
    }
        
    private func configure(model: ProfileModel) {
        nameLabel.text = model.results?.userName
        idLabel.text = "@" + (model.results?.id ?? "")
        collectionView.reloadData()
    }
    
    // 유저 타입별 분기 처리
    private func configureActionButtonUI(model: ProfileModel) {
        guard let viewModel = viewModel else { return }
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
        
        buttonStack.addArrangedSubview(friendActionButton)
        friendActionButton.tintColor = viewModel.relationShip.tintColor
        friendActionButton.backgroundColor = viewModel.relationShip.backgroundColor
        friendActionButton.setAttributedTitle(viewModel.relationShip.attributedTitle, for: .normal)
        
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

extension ProfileInfoView: UICollectionViewDelegate {
    
}

extension ProfileInfoView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let viewModel = viewModel else { return CGSize(width: 0, height: 0) }
        return viewModel.getCellSize()
    }
}

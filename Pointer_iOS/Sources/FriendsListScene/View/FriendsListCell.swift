//
//  FriendsListCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/13.
//

import UIKit
import SnapKit
import RxGesture
import RxSwift

protocol FriendsListCellDelegate: AnyObject {
    func userSelected(user: FriendsListResultData)
}

class FriendsListCell: UICollectionViewCell {
    //MARK: - Properties
    static let cellIdentifier = "FriendsListCell"
    weak var friendsListCellDelegate: FriendsListCellDelegate?
    weak var relationshipDelegate: RelationshipFriendActionDelegate?
    var disposeBag = DisposeBag()
    
    var isSelectedCell: Bool = false {
        didSet {
            configureSelected()
        }
    }
    
    var userData: FriendsModel? {
        didSet {
            configure()
        }
    }
    
    var user: FriendsListResultData? {
        didSet {
            configure()
        }
    }
    
    var viewType: FriendsListViewModel.ListType?
    
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
    
    private let selectImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.unselectedCheck
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var relationshipActionView: RelationshipFriendActionView?
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        selectImageView.rx.tapGesture().when(.recognized)
            .subscribe { [weak self] _ in
                guard let self = self,
                      let user = self.user else { return }
                self.isSelectedCell.toggle()
                self.friendsListCellDelegate?.userSelected(user: user)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Functions
    private func setupUI() {
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
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
            $0.leading.equalTo(profileImageView.snp.trailing).inset(-10)
        }
        
        guard let viewType = viewType else { return }
        switch viewType {
        case .normal:
            break
        case .select:
            addSubview(selectImageView)
            selectImageView.snp.makeConstraints {
                $0.width.height.equalTo(self.snp.height).dividedBy(1.8)
                $0.trailing.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    private func configure() {
        guard let user = userData else { return }
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: URL(string: user.file ?? ""))
        
        userIdLabel.text = user.id
        userNameLabel.text = user.friendName
        
        // 뷰 타입이 노말인 경우만
        if viewType == .normal {
            // reuse 된 경우
            if let view = self.relationshipActionView {
                view.removeFromSuperview()
                self.relationshipActionView = nil
            }
            // 새로 만든 경우
            let actionButtonView = RelationshipFriendActionView(userId: user.friendId, relationship: Relationship(rawValue: user.relationship) ?? .none, userName: user.friendName, userStringId: user.id)
            actionButtonView.delegate = relationshipDelegate
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
    
    private func configureSelected() {
        selectImageView.image = isSelectedCell ? .selectedCheck: .unselectedCheck
    }
}

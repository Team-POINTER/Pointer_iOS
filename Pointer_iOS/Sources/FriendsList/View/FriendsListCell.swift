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
    func userSelected(user: User)
}

class FriendsListCell: UICollectionViewCell {
    //MARK: - Properties
    static let cellIdentifier = "FriendsListCell"
    var delegate: FriendsListCellDelegate?
    var disposeBag = DisposeBag()
    
    var isSelectedCell: Bool = false {
        didSet {
            configureSelected()
        }
    }
    
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
    
    private let selectImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.unselectedCheck
        view.contentMode = .scaleAspectFill
        return view
    }()
    
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
                      let user = user else { return }
                self.isSelectedCell.toggle()
                self.delegate?.userSelected(user: user)
            }
            .disposed(by: disposeBag)
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
        
        addSubview(selectImageView)
        selectImageView.snp.makeConstraints {
            $0.width.height.equalTo(self.snp.height).dividedBy(1.8)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configure() {
        guard let user = user else { return }
        profileImageView.image = .defaultProfile
        userIdLabel.text = user.userID
        userNameLabel.text = user.userName
    }
    
    private func configureSelected() {
        selectImageView.image = isSelectedCell ? .selectedCheck: .unselectedCheck
    }
}

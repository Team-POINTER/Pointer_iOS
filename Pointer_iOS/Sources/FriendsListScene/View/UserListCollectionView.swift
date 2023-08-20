//
//  UserListCollectionView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/17.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class UserListCollectionView: UIView {
    //MARK: - Properties
    weak var friendsListCelldelegate: FriendsListCellDelegate?
    weak var relationshipDelegate: RelationshipFriendActionDelegate?
    
    /// weak View Model
    weak var viewModel: FriendsListViewModel?
    /// to accept datasource
    let userList = BehaviorRelay<[FriendsModel]>(value: [])
    /// 친구 count Label을 사용할건지?
    var showFriendCountLabel = false
    /// 친구 00명 중 '친구'
    var friendCountTitle = "친구"
    /// 좌 우 간격
    var layoutInset = CGFloat(14)
    
    var disposeBag = DisposeBag()
    private let viewType: FriendsListViewModel.ListType
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSans(font: .notoSansKrMedium, size: 11)
        label.textColor = UIColor(red: 0.7, green: 0.716, blue: 0.804, alpha: 1)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.register(FriendsListCell.self, forCellWithReuseIdentifier: FriendsListCell.cellIdentifier)
        return cv
    }()
    
    //MARK: - Lifecycle
    init(type: FriendsListViewModel.ListType) {
        self.viewType = type
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
        bind()
    }
    
    //MARK: - bind
    private func bind() {
        // 유저 리스트
        self.userList
            .do(onNext: { [weak self] userList in
                guard let self = self else { return }
                self.countLabel.text = "\(self.friendCountTitle) \(userList.count)"
            })
            .bind(to: collectionView.rx.items) { [weak self] collectionView, index, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsListCell.cellIdentifier, for: IndexPath(row: index, section: 0)) as? FriendsListCell else { return UICollectionViewCell() }
                cell.friendsListCellDelegate = self?.friendsListCelldelegate
                cell.relationshipDelegate = self?.relationshipDelegate
                cell.viewType = self?.viewType
                cell.userData = item
                // 뷰모델 바인딩 ( select 체크의 경우 )
                guard let viewModel = self?.viewModel else { return cell }
                cell.isSelectedCell = viewModel.detectSelectedUser(item)
                return cell
            }
            .disposed(by: disposeBag)
        
        // Select - 선택한 유저 바인딩
        if let viewModel = viewModel {
            viewModel.selectedUser
                .bind { [weak self] _ in
                    self?.collectionView.reloadData()
                }
                .disposed(by: disposeBag)
        }
    }
    
    //MARK: - Methods
    private func setupUI() {
        // CountLabel 보여주는 경우
        if showFriendCountLabel {
            addSubview(countLabel)
            countLabel.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(layoutInset)
                $0.top.equalToSuperview()
            }
            
            addSubview(collectionView)
            collectionView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(layoutInset)
                $0.top.equalTo(countLabel.snp.bottom).inset(-3)
                $0.bottom.equalToSuperview()
            }
        } else {
            addSubview(collectionView)
            collectionView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(layoutInset)
                $0.top.bottom.equalToSuperview()
            }
        }
    }
}

extension UserListCollectionView: UICollectionViewDelegate {
    
}

extension UserListCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 55)
    }
}

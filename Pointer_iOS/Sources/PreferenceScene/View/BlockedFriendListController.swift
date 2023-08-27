//
//  BlockedFriendListController.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/27.
//

import UIKit
import RxSwift
import RxCocoa

class BlockedFriendListController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    let viewModel: BlockedFriendListViewModel
    weak var delegate: FriendsListViewControllerDelegate?
    
    let searchHeaderView = FriendsListHeaderView()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .pointerRed
        button.tintColor = .white
        return button
    }()
    
    lazy var collectionView: UserListCollectionView = {
        let view = UserListCollectionView(type: .normal)
        view.showFriendCountLabel = true
        view.friendCountTitle = "차단한 사용자"
        view.friendsListCelldelegate = self
        view.relationshipDelegate = self
        return view
    }()
    
    //MARK: - Lifecycle
    init(viewModel: BlockedFriendListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        bind()
    }
    
    //MARK: - Bind
    private func bind() {
        // 헤더 뷰 검색어 keyword 바인딩
        _ = viewModel.transform(input: .init(searchTextFieldEditEvent: searchHeaderView.searchTextField.rx.text.asObservable()))
        
        viewModel.userList
            .bind(to: collectionView.userList)
            .disposed(by: disposeBag)
        
//        viewModel.requestBlockedFriendList()
    }
    
    //MARK: - Methods
    private func setupUI() {
        view.addSubview(searchHeaderView)
        searchHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(60)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchHeaderView.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupNavigation() {
        self.navigationItem.title = "차단한 사용자"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissButtonTapped))
    }
    
    @objc private func dismissButtonTapped() {
        self.dismiss(animated: true)
    }
}

extension BlockedFriendListController: FriendsListCellDelegate {
    func userSelected(user: FriendsListResultData) {
        
    }
}

extension BlockedFriendListController: RelationshipFriendActionDelegate {
    func showActionAlert(alert: PointerAlert) {
        self.present(alert, animated: true)
    }
    
    func didFriendRelationshipChanged() {
        self.viewModel.requestBlockedFriendList()
    }
}

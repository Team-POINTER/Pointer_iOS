//
//  RoomResultController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

private let roomCellReuseIdentifier = "RoomPreviewCell"
private let accountCellReuseIdentifier = "AccountInfoCell"

class SearchResultController: UIViewController {
    
    // Result Type 에 따라서 컨트롤러 내부 뷰가 달라짐
    // room: 룸 검색 결과
    // accout: 계정 검색 결과
    enum ResultType {
        case room
        case account
    }
    
    //MARK: - Properties
    private let resultType: ResultType
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    
    private var roomData: [PointerRoomModel] = []
    
    private var accountData: [SearchUserListModel] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()

    
    //MARK: - Lifecycle
    init(withResultType type: ResultType, viewModel: SearchViewModel) {
        self.resultType = type
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        bind()
    }
    
    //MARK: - Bind
    func bind() {
        viewModel.searchRoomResult
            .subscribe(onNext: { [weak self] data in
                self?.roomData = data.roomList
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.searchAccountResult
            .subscribe(onNext: { [weak self] data in
                self?.accountData = data
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Functions
    private func setupCollectionView() {
        collectionView.register(RoomPreviewCell.self, forCellWithReuseIdentifier: roomCellReuseIdentifier)
        collectionView.register(AccountInfoCell.self, forCellWithReuseIdentifier: accountCellReuseIdentifier)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SearchResultController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch resultType {
        case .room:
            return roomData.count
        case .account:
            return accountData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch resultType {
        case .room:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: roomCellReuseIdentifier, for: indexPath) as? RoomPreviewCell else { return UICollectionViewCell() }
            
            let model = RoomCellViewModel(roomModel: roomData[indexPath.row])
            
            cell.roomViewModel = model
            
            return cell
            
        case .account:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: accountCellReuseIdentifier, for: indexPath) as? AccountInfoCell else { return UICollectionViewCell() }
            
            let model = accountData[indexPath.row]
            cell.delegate = self
            cell.accountModel = model
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch resultType {
        case .room:
            let model = roomData[indexPath.row]
            viewModel.tapedRoomResult.accept(model)
        case .account:
            let model = accountData[indexPath.row]
            viewModel.tapedProfileResult.accept(model)
        }
    }
}

extension SearchResultController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch resultType {
        case .room:
            return CGSize(width: collectionView.frame.width - 32, height: 160)
        case .account:
            return CGSize(width: collectionView.frame.width - 32, height: 54)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch resultType {
        case .room:
            return 18
        case .account:
            return 0
        }
    }
}

extension SearchResultController: RelationshipFriendActionDelegate {
    func showActionAlert(alert: PointerAlert) {
        self.present(alert, animated: true)
    }
    
    func didFriendRelationshipChanged() {
        viewModel.requestAccountList(word: viewModel.lastSearchedKeyword, lastPage: 0)
    }
}

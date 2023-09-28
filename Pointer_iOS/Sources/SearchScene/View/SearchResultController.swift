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
import FloatingPanel

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

    private lazy var fpc = FloatingPanelController.getFloatingPanelViewController(delegate: self)
    
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
                self?.roomData = data
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
            cell.delegate = self
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.height // 스크롤뷰의 전체 높이
        let contentSizeHeight = scrollView.contentSize.height // 전체 콘텐츠 영역의 높이
        let offset = scrollView.contentOffset.y // 클릭 위치
        let reachedBottom = (offset > contentSizeHeight - height) // (클릭 지점 + 스크롤뷰 높이 == 전체 컨텐츠 높이) -> Bool

        if resultType == .account {
            if reachedBottom && (contentSizeHeight > height) { // 스크롤이 바닥에 닿았다면 & 컨텐츠가 스크롤 가능한 높이일 때
              scrollViewDidReachBottom(scrollView)
            }
        }
    }
    
    func scrollViewDidReachBottom(_ scrollView: UIScrollView) {
        viewModel.refetchUserResult.accept(())
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
        viewModel.didFriendRelationChanged()
    }
}

//MARK: - RoomCellDelegate
extension SearchResultController: RoomPreviewCellDelegate {
    func roomCellActionImageTapped(roomId: Int, currentName: String, questionId: Int, questionCreatorId: Int) {
        let modifyRoomName = PointerAlertActionConfig(title: "룸 이름 편집", textColor: .black) { [weak self] _ in
            guard let self = self else { return }
            let alert = self.viewModel.getModifyRoomNameAlert(currentName, roomId: roomId)
            self.present(alert, animated: true)
        }
        let inviteRoomWithLink = PointerAlertActionConfig(title: "친구 초대하기", textColor: .black) { [weak self] _ in
            let viewModel = FriendsListViewModel(listType: .select, roomId: roomId)
            let viewController = FriendsListViewController(viewModel: viewModel)
            viewController.delegate = self
            self?.navigationController?.pushViewController(viewController, animated: true)

        }
        let report = PointerAlertActionConfig(title: "질문 신고하기", textColor: .red) { [weak self] _ in
            self?.reportTap(roomId: roomId, currentName: currentName, questionId: questionId, questionCreatorId: questionCreatorId)
        }
        let exitRoom = PointerAlertActionConfig(title: "룸 나가기", textColor: .pointerRed, font: .boldSystemFont(ofSize: 18)) { [weak self] _ in
            guard let alert = self?.viewModel.getExitRoomAlert(roomId: roomId) else { return }
            self?.present(alert, animated: true)
        }
        let actionSheet = PointerAlert(alertType: .actionSheet,
                                       configs: [modifyRoomName, inviteRoomWithLink, report, exitRoom],
                                       title: "룸 '\(currentName)'에 대해")
        present(actionSheet, animated: true)
    }
    
    func reportTap(roomId: Int, currentName: String, questionId: Int, questionCreatorId: Int) {
        var sheetConfig = [PointerAlertActionConfig]()
        
        ReasonCode.allCases.forEach { type in
            let config = PointerAlertActionConfig(title: type.reason, textColor: .black) { [weak self] _ in
                self?.presentReportView(roomId: roomId, currentName: currentName, questionId: questionId, questionCreatorId: questionCreatorId, reasonCode: type.rawValue, presentingReason: type.reason)
            }
            sheetConfig.append(config)
        }
        
        let actionSheet = PointerAlert(alertType: .actionSheet, configs: sheetConfig, title: "신고 사유")
        present(actionSheet, animated: true)
    }
    
    func presentReportView(roomId: Int, currentName: String, questionId: Int, questionCreatorId: Int, reasonCode: String, presentingReason: String) {
        let reportVM = ReportViewModel(roomId: roomId,
                                       questionId: questionId,
                                       type: .question,
                                       targetUserId: questionCreatorId,
                                       presentingReason: presentingReason,
                                       reasonCode: reasonCode)
        
        let reportVC = ReportViewController(viewModel: reportVM)
        fpc.set(contentViewController: reportVC)
        fpc.track(scrollView: reportVC.scrollView)
        self.present(fpc, animated: true)
    }
}

//MARK: - FriendsListViewControllerDelegate
extension SearchResultController: FriendsListViewControllerDelegate {
    func dismissInviteView() {
        self.viewModel.requestRoomList("")
    }
}

//
//  NotificationDetailViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/26.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

private let roomCellIdentifier = "allNotiCell"
private let friendCellReuseIdentifier = "friendsNotiCell"

protocol NewNotiIconDelegate: AnyObject {
    func newNotiStatus(room: Bool, friend: Bool)
    func friendNotiDidRead()
}

class NotificationDetailViewController: UIViewController {
    
    // Result Type 에 따라서 컨트롤러 내부 뷰가 달라짐
    // all: 전체 알림
    // friends: 친구 신청 관련
    enum NotiType {
        case room(viewModel: NotiDetailViewModel)
        case friends(viewModel: NotiDetailViewModel)
        
        var viewModel: NotiDetailViewModel {
            switch self {
            case .friends(let viewModel):
                return viewModel
            case .room(viewModel: let viewModel):
                return viewModel
            }
        }
        
        var emptyViewTitle: String {
            switch self {
            case .room:
                return "아직 알림이 없어요"
            case .friends:
                return "아직 친구 요청이 없어요"
            }
        }
        
        var emptyViewSubTitle: String {
            switch self {
            case .room:
                return "활동 알림이 오면 여기에 표시돼요."
            case .friends:
                return "친구 요청을 받으면 여기에 표시돼요."
            }
        }
    }
    
    //MARK: - Properties
    let notiType: NotiType
    var viewModel: NotiDetailViewModel
    let disposeBag = DisposeBag()
    
    weak var containerViewController: NotificationViewController?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(RoomNotiCell.self, forCellWithReuseIdentifier: roomCellIdentifier)
        cv.register(FriendsNotiCell.self, forCellWithReuseIdentifier: friendCellReuseIdentifier)
        cv.delegate = self
        return cv
    }()
    
    private let emptyView = ListEmptyView()
    
    //MARK: - Lifecycle
    init(withNotificationType type: NotiType, delegate: NewNotiIconDelegate) {
        self.notiType = type
        self.viewModel = type.viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    //MARK: - Bind
    private func bind() {
        viewModel.dataSources
            .do(onNext: { [weak self] list in
                print(list)
                self?.emptyView.isHidden = !list.isEmpty
            })
            .bind(to: collectionView.rx.items) { [weak self] collectionView, index, item in
                guard let self = self else { return UICollectionViewCell() }
                switch self.notiType {
                case .room:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: roomCellIdentifier, for: IndexPath(row: index, section: 0)) as? RoomNotiCell,
                          let item = item as? RoomAlarmList else { return UICollectionViewCell() }
                    cell.item = item
                    return cell
                case .friends:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friendCellReuseIdentifier, for: IndexPath(row: index, section: 0)) as? FriendsNotiCell,
                          let item = item as? FriendAlarmList else { return UICollectionViewCell() }
                    cell.delegate = self
                    cell.item = item
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        // 다음 뷰
        viewModel.nextViewController
            .bind { [weak self] viewController in
                guard let self = self,
                      let vc = viewController,
                      let homeNavi = sceneDelegate?.appCoordinator?.tabBarController.viewControllers?.first as? UINavigationController else { return }
                self.containerViewController?.dismissWithNavigationPopStyle {
                    homeNavi.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Any.self)
            .bind { [weak self] item in
                guard let self = self else { return }
                self.viewModel.notificationItemTapped(type: self.notiType, item: item)
            }
            .disposed(by: disposeBag)
        
        viewModel.requestData()
    }
    
    //MARK: - Functions
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(100)
        }
        
        emptyView.isHidden = true
        
        emptyView.titleText = notiType.emptyViewTitle
        emptyView.subtitleText = notiType.emptyViewSubTitle
    }
}

extension NotificationDetailViewController: UICollectionViewDelegate {
    
}

extension NotificationDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch notiType {
        case .room:
            return CGSize(width: collectionView.frame.width - 32, height: 91)
        case .friends:
            return CGSize(width: collectionView.frame.width - 32, height: 54)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch notiType {
        case .room:
            return 0
        case .friends:
            return 0
        }
    }
}

extension NotificationDetailViewController: RelationshipFriendActionDelegate {
    func showActionAlert(alert: PointerAlert) {
        self.present(alert, animated: true)
    }
    
    func didFriendRelationshipChanged() {
        viewModel.requestData()
    }
}

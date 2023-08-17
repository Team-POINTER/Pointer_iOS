//
//  HomeController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/10.
//

import UIKit
import RxSwift
import SnapKit

class HomeController: BaseViewController {
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private lazy var refreshControl = PointerRefreshControl(target: self) { [weak self] in
        self?.viewModel.requestRoomList()
    }
    
    private let logoImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "pointer_logo_main"))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 120).isActive = true
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 18
        layout.minimumLineSpacing = 18
        layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(RoomPreviewCell.self, forCellWithReuseIdentifier: RoomPreviewCell.identifier)
        cv.refreshControl = refreshControl
        cv.delegate = self
        return cv
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin, scale: .default)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.backgroundColor = .pointerRed
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleActionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let viewModel = HomeViewModel()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationController()
        bind()
    }
    
    //MARK: - Bind
    private func bind() {
        let input = HomeViewModel.Input()
        _ = viewModel.transform(input: input)
        
        viewModel.roomModel
            .do(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .bind(to: collectionView.rx.items) { [weak self] collectionView, index, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoomPreviewCell.identifier, for: IndexPath(row: index, section: 0)) as? RoomPreviewCell else { return UICollectionViewCell() }
                cell.roomViewModel = self?.viewModel.getRoomViewModel(index: index)
                cell.delegate = self
                return cell
            }
            .disposed(by: disposeBag)
            
        Observable
            .zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(PointerRoomModel.self))
            .bind { [weak self] indexPath, model in
                self?.viewModel.pushSingleRoomController(voted: model.voted,
                                                         roomId: model.roomId,
                                                         questionId: model.questionId,
                                                         limitedAt: model.limitedAt)
            }
            .disposed(by: disposeBag)
        
        viewModel.pusher
            .bind { [weak self] viewController in
                if let vc = viewController {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.presenter
            .bind { [weak self] viewController in
                if let vc = viewController {
                    let nav = BaseNavigationController.templateNavigationController(nil, viewController: vc)
                    self?.tabBarController?.presentWithNavigationPushStyle(nav)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.expiredToken
            .bind { [weak self] b in
                if b {
                    self?.handleNotiLogoutTapped()
                }
            }
            .disposed(by: disposeBag)
        
        logoImageView.rx.tapGesture()
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] _ in
                self?.viewModel.roomModel.accept([])
                self?.viewModel.requestRoomList()
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - Selector
    @objc private func handleSearchButtonTapped() {
        let vc = SearchController(viewModel: SearchViewModel())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleNotiButtonTapped() {
        let vc = NotificationViewController()
        let nav = BaseNavigationController.templateNavigationController(nil, title: "알림", viewController: vc)
        self.tabBarController?.presentWithNavigationPushStyle(nav)
    }
    
    @objc private func handleNotiLogoutTapped() {
        sceneDelegate?.appCoordinator?.logout()
    }
    
    @objc private func handleActionButtonTapped() {
        let alert = viewModel.getCreateRoomNameAlert()
        present(alert, animated: true)
    }
    
    //MARK: - Functions
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.width.height.equalTo(62)
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(13)
            actionButton.layer.cornerRadius = 62 / 2
            actionButton.clipsToBounds = true
        }
    }
    
    private func setupNavigationController() {
        // 로고
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        navigationItem.leftBarButtonItem = imageItem
        
        // 우측 바버튼
        let notiImage = UIImage(systemName: "bell")
        let searchImage = UIImage(systemName: "magnifyingglass")

        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: notiImage, size: 45, target: self, handler: #selector(handleNotiButtonTapped))
        let searchButton = UIBarButtonItem.getPointerBarButton(withIconimage: searchImage, size: 45, target: self, handler: #selector(handleSearchButtonTapped))
        
        // (임시)로그아웃
        let logoutImage = UIImage(systemName: "arrow.up.forward")

        let logoutButton = UIBarButtonItem.getPointerBarButton(withIconimage: logoutImage, size: 45, target: self, handler: #selector(handleNotiLogoutTapped))

        navigationItem.rightBarButtonItems = [notiButton, searchButton, logoutButton]
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 160)
    }
}

//MARK: - RoomCellDelegate
extension HomeController: RoomPreviewCellDelegate {
    func roomCellActionImageTapped(roomId: Int, _ currentName: String) {
        let modifyRoomName = PointerAlertActionConfig(title: "룸 이름 편집", textColor: .black) { [weak self] _ in
            guard let self = self else { return }
            let alert = self.viewModel.getModifyRoomNameAlert(currentName, roomId: roomId)
            self.present(alert, animated: true)
        }
        let inviteRoomWithLink = PointerAlertActionConfig(title: "링크로 룸 초대", textColor: .black) { _ in
            print("DEBUG - 링크로 룸 초대 눌림")
        }
        let exitRoom = PointerAlertActionConfig(title: "룸 나가기", textColor: .pointerRed, font: .boldSystemFont(ofSize: 18)) { [weak self] _ in
            guard let alert = self?.viewModel.getExitRoomAlert(roomId: roomId) else { return }
            self?.present(alert, animated: true)
        }
        let actionSheet = PointerAlert(alertType: .actionSheet,
                                       configs: [modifyRoomName, inviteRoomWithLink, exitRoom],
                                       title: "룸 '\(currentName)'에 대해")
        present(actionSheet, animated: true)
    }
}

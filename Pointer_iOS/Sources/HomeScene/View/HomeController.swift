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
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 18
        layout.minimumLineSpacing = 18
        layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
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
        setupCollectionView()
        bind()
    }
    
    //MARK: - Bind
    private func bind() {
        let input = HomeViewModel.Input()
        _ = viewModel.transform(input: input)
        
        viewModel.roomModel
            .bind(to: collectionView.rx.items) { [weak self] collectionView, index, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoomPreviewCell.identifier, for: IndexPath(row: index, section: 0)) as? RoomPreviewCell else { return UICollectionViewCell() }
                cell.roomViewModel = self?.viewModel.getRoomViewModel(index: index)
                cell.delegate = self
                return cell
            }
            .disposed(by: disposeBag)
            
    }
    
    //MARK: - Selector
    @objc private func handleSearchButtonTapped() {
        let vc = SearchController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleNotiButtonTapped() {
        let vc = NotificationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleNotiLogoutTapped() {
        TokenManager.resetUserToken()
        guard let tabVc = tabBarController as? BaseTabBarController else { return }
        tabVc.viewControllers = []
        tabVc.configureAuth()
    }
    
    @objc private func something() {
        print(#function)
    }
    
    @objc private func handleActionButtonTapped() {

    }
    
    //MARK: - Functions
    private func modifyRoomNameAction() {
        let cancelAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 18), handler: nil)
        let confirmAction = PointerAlertActionConfig(title: "완료", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansBold(size: 18)) {
            if let text = $0 {
                print("DEBUG - 방이름 : \(text)")
            } else {
                print("변경 내역 없음")
            }
        }
        let customView = CustomTextfieldView(roomName: "임시 방 이름", withViewHeight: 50)
        let alert = PointerAlert(alertType: .alert, configs: [cancelAction, confirmAction], title: "방 이름 변경", description: "변경할 이름을 입력해주세요", customView: customView)
        self.present(alert, animated: true)
    }
    
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
    
    private func setupCollectionView() {
        collectionView.register(RoomPreviewCell.self, forCellWithReuseIdentifier: RoomPreviewCell.identifier)
        collectionView.delegate = self
    }
    
    private func setupNavigationController() {
        // 로고
        let logoImageView = UIImageView(image: UIImage(named: "pointer_logo_main"))
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        logoImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
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
    func roomCellActionImageTapped() {
        let modifyRoomName = PointerAlertActionConfig(title: "룸 이름 편집", textColor: .black) { [weak self] _ in
            print("DEBUG - 룸 이름 편집 눌림")
            self?.modifyRoomNameAction()
        }
        let inviteRoomWithLink = PointerAlertActionConfig(title: "링크로 룸 초대", textColor: .black) { _ in
            print("DEBUG - 링크로 룸 초대 눌림")
        }
        let exitRoom = PointerAlertActionConfig(title: "룸 나가기", textColor: .pointerRed, font: .boldSystemFont(ofSize: 18)) { _ in
            print("DEBUG - 룸 나가기 눌림")
        }
        let actionSheet = PointerAlert(alertType: .actionSheet, configs: [modifyRoomName, inviteRoomWithLink, exitRoom])
        present(actionSheet, animated: true)
    }
}

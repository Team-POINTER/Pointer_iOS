//
//  NotificationDetailViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/26.
//

import UIKit
import SnapKit

private let allNotiCellReuseIdentifier = "allNotiCell"
private let friendsNotiCellReuseIdentifier = "friendsNotiCell"

class NotificationDetailViewController: UIViewController {
    
    // Result Type 에 따라서 컨트롤러 내부 뷰가 달라짐
    // all: 전체 알림
    // friends: 친구 신청 관련
    enum NotiType {
        case all
        case friends
    }
    
    //MARK: - Properties
    let notiType: NotiType
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    //MARK: - Lifecycle
    init(withNotificationType type: NotiType) {
        self.notiType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupUI()
    }
    
    //MARK: - Selector
    
    //MARK: - Functions
    private func setupCollectionView() {
        collectionView.register(AllNotiCell.self, forCellWithReuseIdentifier: allNotiCellReuseIdentifier)
        collectionView.register(FriendsNotiCell.self, forCellWithReuseIdentifier: friendsNotiCellReuseIdentifier)
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

extension NotificationDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch notiType {
        case .all:
            return 10
        case .friends:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch notiType {
        case .all:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: allNotiCellReuseIdentifier, for: indexPath) as? AllNotiCell else { return UICollectionViewCell() }
            return cell
        case .friends:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friendsNotiCellReuseIdentifier, for: indexPath) as? FriendsNotiCell else { return UICollectionViewCell() }
            return cell
        }
    }
}

extension NotificationDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch notiType {
        case .all:
            return CGSize(width: collectionView.frame.width - 32, height: 160)
        case .friends:
            return CGSize(width: collectionView.frame.width - 32, height: 54)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch notiType {
        case .all:
            return 18
        case .friends:
            return 0
        }
    }
}

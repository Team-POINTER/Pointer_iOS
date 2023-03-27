//
//  RoomResultController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/19.
//

import UIKit
import SnapKit

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
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()

    
    //MARK: - Lifecycle
    init(withResultType type: ResultType) {
        self.resultType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    //MARK: - Selector
    
    //MARK: - Functions
    private func setupCollectionView() {
        collectionView.register(RoomPreviewCell.self, forCellWithReuseIdentifier: roomCellReuseIdentifier)
        collectionView.register(AccountInfoCell.self, forCellWithReuseIdentifier: accountCellReuseIdentifier)
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
            return 10
        case .account:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch resultType {
        case .room:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: roomCellReuseIdentifier, for: indexPath) as? RoomPreviewCell else { return UICollectionViewCell() }
            return cell
        case .account:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: accountCellReuseIdentifier, for: indexPath) as? AccountInfoCell else { return UICollectionViewCell() }
            return cell
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

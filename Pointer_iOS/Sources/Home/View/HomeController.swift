//
//  HomeController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/10.
//

import UIKit
import SnapKit

private let reuseIdentifier = "RoomPreviewCell"

class HomeController: BaseViewController {
    //MARK: - Properties
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 18
        layout.minimumLineSpacing = 18
        layout.sectionInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationController()
        setupCollectionView()
    }
    
    //MARK: - Selector
    @objc private func handleSearchButtonTapped() {
        print(#function)
    }
    
    @objc private func handleNotiButtonTapped() {
        print(#function)
    }
    
    //MARK: - Functions
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupCollectionView() {
        collectionView.register(RoomPreviewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupNavigationController() {
        // 로고
        let logoImageView = UIImageView(image: UIImage(named: "pointer_logo_main"))
        logoImageView.frame = CGRect(x: 0, y: 0, width: 120, height: 70)
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        logoImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        navigationItem.leftBarButtonItem = imageItem
        
        // 우측 바버튼
        let notiImage = UIImage(systemName: "bell")
        let searchImage = UIImage(systemName: "magnifyingglass")

        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: notiImage, size: 45, target: self, handler: #selector(handleNotiButtonTapped))
        let searchButton = UIBarButtonItem.getPointerBarButton(withIconimage: searchImage, size: 45, target: self, handler: #selector(handleSearchButtonTapped))
        
        navigationItem.rightBarButtonItems = [notiButton, searchButton]
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? RoomPreviewCell else { return UICollectionViewCell() }
        return cell
    }
}

extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 160)
    }
}

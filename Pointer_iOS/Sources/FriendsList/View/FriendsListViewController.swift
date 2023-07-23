//
//  FriendsListViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/13.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

class FriendsListViewController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    let viewModel: FriendsListViewModel
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.register(FriendsListCell.self, forCellWithReuseIdentifier: FriendsListCell.cellIdentifier)
        cv.register(FriendsListHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FriendsListHeaderView.headerIdentifier)
        return cv
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .pointerRed
        button.tintColor = .white
        return button
    }()
    
    //MARK: - Lifecycle
    init(type: FriendsListViewModel.ListType) {
        self.viewModel = FriendsListViewModel(listType: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bind()
    }
    
    //MARK: - bind
    func bind() {
        let input = FriendsListViewModel.Input()
        let output = viewModel.transform(input: input)

        // CollectionView 바인딩
        viewModel.friendsList
            .bind(to: collectionView.rx.items(dataSource: viewModel.makeDataSource()))
            .disposed(by: disposeBag)
        
        confirmButton.setAttributedTitle(viewModel.getInitialButtonAttributeString(), for: .normal)
        
        output.buttonAttributeString
            .bind { [weak self] attribute in
                self?.confirmButton.setAttributedTitle(attribute, for: .normal)
            }
            .disposed(by: disposeBag)
        
        
//        Observable
//            .zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(User.self))
//            .subscribe { [weak self] indexPath, item in
//                guard let cell = self?.collectionView.cellForItem(at: indexPath) as? FriendsListCell else { return }

//            }
//            .disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func linkButtonTapped() {
        print("Link Button Tapped")
    }
    
    @objc private func plusButtonTapped() {
        print("plus Button Tapped")
    }
    
    //MARK: - Functions
    func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(collectionView)
        
        switch viewModel.listType {
        // 타입이 Select일 경우
        case .select:
            // 버튼 추가
            view.addSubview(confirmButton)
            confirmButton.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(60)
                $0.bottom.equalTo(view.safeAreaLayoutGuide)
                confirmButton.layer.cornerRadius = 60 / 2
                confirmButton.clipsToBounds = true
            }
            
            collectionView.snp.makeConstraints {
                $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
                $0.bottom.equalTo(confirmButton.snp.top)
            }
        // 타입이 Normal일 경우
        case .normal:
            collectionView.snp.makeConstraints {
                $0.edges.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }
    
    func setupNavigationBar() {
        switch viewModel.listType {
        case .select:
            navigationItem.title = "룸 이름"
            navigationItem.leftBarButtonItem = UIBarButtonItem.getPointerBackBarButton(target: self, handler: #selector(backButtonTapped))
            
            let linkImage = UIImage(systemName: "link")
            let rightBarButton = UIBarButtonItem.getPointerBarButton(withIconimage: linkImage, target: self, handler: #selector(linkButtonTapped))
            navigationItem.rightBarButtonItem = rightBarButton
        case .normal:
            navigationItem.title = "OOO님의 친구"
            navigationItem.leftBarButtonItem = UIBarButtonItem.getPointerBackBarButton(target: self, handler: #selector(backButtonTapped))
            
            let plusImage = UIImage(systemName: "plus")
            let rightBarButton = UIBarButtonItem.getPointerBarButton(withIconimage: plusImage, target: self, handler: #selector(plusButtonTapped))
            navigationItem.rightBarButtonItem = rightBarButton
        }
    }
}

//MARK: - UIcollectionViewDelegate
extension FriendsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 60)
    }
}

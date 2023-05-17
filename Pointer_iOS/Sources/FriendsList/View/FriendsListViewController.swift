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
        layout.sectionInset = UIEdgeInsets(top: 17.5, left: 0, bottom: 17.5, right: 0)
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

    
    //MARK: - Functions
    func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
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
        // 타입이 Normal일 경우
        case .normal:
            break
        }
    }
}

//MARK: - UIcollectionViewDelegate
extension FriendsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }
}

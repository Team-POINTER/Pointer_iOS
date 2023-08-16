//
//  PreferenceController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

private let cellIdentifier = "PreferenceItemCell"
private let headerIdentifier = "PreferenceItemHeader"
private let background = "backgroundViewIdentifier"

class PreferenceController: BaseViewController {
    //MARK: - Properties
    let viewModel = PreferenceViewModel()
    let disposeBag = DisposeBag()
    lazy var collectionView: UICollectionView = {
        let layout = generateLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(PreferenceItemCell.self, forCellWithReuseIdentifier: cellIdentifier)
        cv.register(PreferenceItemHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    //MARK: - Selector
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Functions
    func bind() {
        _ = viewModel.transform(
            input: PreferenceViewModel.Input(collectionItemSelected: collectionView.rx.itemSelected.asObservable()))
        
        viewModel.preferenceData
            .bind { [weak self] data in
                if !data.isEmpty {
                    self?.collectionView.reloadData()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.pushInfoData
            .bind { [weak self] data in
                if data != nil {
                    self?.collectionView.reloadData()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.alertView
            .bind { [weak self] alert in
                guard let alert = alert else { return }
                self?.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        // Background - 테두리 뷰
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: background)
        sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 25, trailing: 16)
        section.decorationItems = [sectionBackgroundDecoration]
        
        // Header - 카테고리 구분 헤더
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.boundarySupplementaryItems = [headerItem]
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 40, trailing: 16)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        // Background: DecorationView Register
        layout.register(PreferenceSectionBackgroundView.self, forDecorationViewOfKind: background)
        return layout
    }
    
    private func setupUI() {
        setupNaviBar()
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupNaviBar() {
        navigationItem.title = "설정"
        let backButtonImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButtonImage, size: Device.navigationBarHeight, target: self, handler: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
}

extension PreferenceController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // 섹션의 카운트 - 해당 enum 카운트 갯수
        return PreferenceSectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = PreferenceSectionType(rawValue: section)
        let models = viewModel.preferenceData.value.filter { $0.menu.section == section }
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PreferenceItemCell else { return UICollectionViewCell() }
        cell.delegate = viewModel
        cell.item = viewModel.indexPathToType(indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath) as? PreferenceItemHeader else { return UICollectionReusableView() }
        let type = PreferenceSectionType.allCases[indexPath.section]
        view.headerType = type
        return view
    }
}

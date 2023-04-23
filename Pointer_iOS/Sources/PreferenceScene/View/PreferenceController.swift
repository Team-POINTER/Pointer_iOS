//
//  PreferenceController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit
import SnapKit

let cellIdentifier = "PreferenceItemCell"
let headerIdentifier = "PreferenceItemHeader"

class PreferenceController: BaseViewController {
    //MARK: - Properties
    let viewModel = PreferenceViewModel()
    lazy var collectionView: UICollectionView = {
        let layout = generateLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    //MARK: - Functions
    func setupCollectionView() {
        collectionView.register(PreferenceItemCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(PreferenceItemHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func generateLayout() -> UICollectionViewLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 40, trailing: 16)
        
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [headerItem]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension PreferenceController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // 섹션의 카운트 - 해당 enum 카운트 갯수
        return PreferenceModel.SectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = PreferenceModel.SectionType.allCases[section]
        let typeModel = PreferenceModel.allCases.filter { $0.type == type }
        print("Section: \(type.rawValue), Count: \(typeModel.count)")
        return typeModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PreferenceItemCell else { return UICollectionViewCell() }
        let section = PreferenceModel.SectionType.allCases[indexPath.section]
        let typeModels = PreferenceModel.allCases.filter { $0.type == section }
        let type = typeModels[indexPath.row]
        cell.item = type
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath) as? PreferenceItemHeader else { return UICollectionReusableView() }
        let type = PreferenceModel.SectionType.allCases[indexPath.section]
        view.headerType = type
        return view
    }
}

//
//  FriendsListViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/13.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FriendsListViewModel: ViewModelType {
    //MARK: - ListType
    enum ListType {
        case normal
        case select
    }
    
    //MARK: - Properties
    let listType: ListType
    let friendsList = BehaviorRelay<[SectionModel]>(value: [SectionModel(header: "header", items: User.getDummyUsers())])
    
    //MARK: - Rx
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    //MARK: - Transform
    func transform(input: Input) -> Output {
        let output = Output()
        return output
    }
    
    //MARK: - LifeCycle
    init(listType: ListType) {
        self.listType = listType
    }
    
    //MARK: - DataSources
    struct SectionModel {
        var header: String?
        var footer: String?
        var items: [Item]
    }
    
    func makeDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel>(configureCell: { datasource, collectionView, indexPath, item in
            // Cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsListCell.cellIdentifier, for: indexPath) as? FriendsListCell else { return UICollectionViewCell() }
            cell.user = item
            return cell
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            // Header
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FriendsListHeaderView.headerIdentifier, for: indexPath)
                return header
            default:
                fatalError()
            }
        })
        
        return dataSource
    }
}


extension FriendsListViewModel.SectionModel: SectionModelType {
    typealias Item = User
    
    init(original: FriendsListViewModel.SectionModel, items: [User]) {
        self = original
        self.items = items
    }
}

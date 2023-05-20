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
    var disposeBag = DisposeBag()
    let listType: ListType
    let friendsList = BehaviorRelay<[SectionModel]>(value: [SectionModel(header: "header", items: User.getDummyUsers())])
    let selectedUser = BehaviorRelay<[User]>(value: [])
    
    //MARK: - Rx
    struct Input {
        
    }
    
    struct Output {
        let buttonAttributeString = PublishRelay<NSAttributedString>()
    }
    
    //MARK: - Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        selectedUser
            .subscribe { [weak self] users in
                guard let self = self,
                      let users = users.element else { return }
                let buttonAttributeString = self.makeButtonAttributeString(count: users.count)
                output.buttonAttributeString.accept(buttonAttributeString)
            }
            .disposed(by: disposeBag)
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
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel>(configureCell: { [weak self] datasource, collectionView, indexPath, item in
            // Cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsListCell.cellIdentifier, for: indexPath) as? FriendsListCell,
                  let self = self else { return UICollectionViewCell() }
            cell.user = item
            cell.isSelectedCell = detectSelectedUser(item)
            cell.delegate = self
            return cell
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            // Header
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FriendsListHeaderView.headerIdentifier, for: indexPath) as? FriendsListHeaderView else { return UICollectionReusableView() }
                header.delegate = self
                return header
            default:
                fatalError()
            }
        })
        
        return dataSource
    }
    
    // User가 선택된 상태인지 체크하는 메소드
    private func detectSelectedUser(_ selectedUser: User) -> Bool {
        var isSelectedUser = false
        for user in self.selectedUser.value {
            if user.uid == selectedUser.uid {
                isSelectedUser = true
                break
            }
        }
        return isSelectedUser
    }
    
    // User Select 이벤트가 들어오면 실행하는 함수
    private func processSelectedUser(selectedUser: User) {
        var currentSelectedUser = self.selectedUser.value
        let isUserSelected = detectSelectedUser(selectedUser)
        switch isUserSelected {
        case true:
            currentSelectedUser.enumerated().forEach { index, user in
                if selectedUser.uid == user.uid {
                    currentSelectedUser.remove(at: index)
                    self.selectedUser.accept(currentSelectedUser)
                }
            }
        case false:
            currentSelectedUser.append(selectedUser)
            self.selectedUser.accept(currentSelectedUser)
        }
    }
    
    private func makeButtonAttributeString(count: Int) -> NSAttributedString {
        let attribute = NSAttributedString(string: "\(count) 확인", attributes: [NSAttributedString.Key.font: UIFont.notoSans(font: .notoSansKrMedium, size: 18)])
        return attribute
    }
    
    func getInitialButtonAttributeString() -> NSAttributedString {
        let attribute = makeButtonAttributeString(count: selectedUser.value.count)
        return attribute
    }
}

//MARK: - FriendsListViewModel.SectionModel
extension FriendsListViewModel.SectionModel: SectionModelType {
    typealias Item = User
    
    init(original: FriendsListViewModel.SectionModel, items: [User]) {
        self = original
        self.items = items
    }
}

//MARK: - FriendsListHeaderSearchBarDelegate
extension FriendsListViewModel: FriendsListHeaderSearchBarDelegate {
    func textFieldDidChange(text: String) {
        print(text)
    }
}

//MARK: - FriendsListCellDelegate
extension FriendsListViewModel: FriendsListCellDelegate {
    func userSelected(user: User) {
        processSelectedUser(selectedUser: user)
    }
}

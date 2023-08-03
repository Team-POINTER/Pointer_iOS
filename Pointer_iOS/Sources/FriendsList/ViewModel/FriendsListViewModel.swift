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
    let friendsListObservable = PublishRelay<[SectionModel]>()
    let friendsList = BehaviorRelay<[SectionModel]>(value: [SectionModel(header: "header", items: [])])
    let selectedUser = BehaviorRelay<[FriendsListResultData]>(value: [])
    
    let roomId: Int?
    
    
    //MARK: - Rx
    struct Input {
        let searchTextFieldEditEvent: Observable<String>
    }
    
    struct Output {
        let buttonAttributeString = PublishRelay<NSAttributedString>()
    }
    
    //MARK: - Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.searchTextFieldEditEvent
            .subscribe { [weak self] text in
                guard let self = self,
                      let text = text.element else { return }
                print(text)
                
                //MARK: [FIX ME] lastPage 값이 어떤 값인가? - 무한 스크롤 시
                let model = InviteFriendsListReqeustInputModel(keyword: text, lastPage: 0)
                self.inviteFriendsListRequest(model)
            }
            .disposed(by: disposeBag)
        
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
    init(listType: ListType, roomId: Int? = nil) {
        self.listType = listType
         self.roomId = roomId
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
            cell.isSelectedCell = self.detectSelectedUser(item)
            cell.delegate = self
            return cell
        })
        
        return dataSource
    }
    
    // User가 선택된 상태인지 체크하는 메소드
    private func detectSelectedUser(_ selectedUser: FriendsListResultData) -> Bool {
        var isSelectedUser = false
        for user in self.selectedUser.value {
            if user.id == selectedUser.id {
                isSelectedUser = true
                break
            }
        }
        return isSelectedUser
    }
    
    // User Select 이벤트가 들어오면 실행하는 함수
    private func processSelectedUser(selectedUser: FriendsListResultData) {
        var currentSelectedUser = self.selectedUser.value
        let isUserSelected = detectSelectedUser(selectedUser)
        switch isUserSelected {
        case true:
            currentSelectedUser.enumerated().forEach { index, user in
                if selectedUser.id == user.id {
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
    
//MARK: - API
    // 초대 가능한 친구 목록
    func inviteFriendsListRequest(_ input: InviteFriendsListReqeustInputModel) {
        guard let roomId = roomId else { return }
        RoomNetworkManager.shared.inviteFriendListRequest(roomId, input) { [weak self] error, model in
            if let error = error {
                print("DEBUG: 초대 가능한 친구 목록 조회 에러 - \(error.localizedDescription)")
            }
            
            if let model = model {
                let sectionModel = [SectionModel(header: "header", items: model)]
                self?.friendsListObservable.accept(sectionModel)
            }
        }
    }
    
}

//MARK: - FriendsListViewModel.SectionModel
extension FriendsListViewModel.SectionModel: SectionModelType {
    typealias Item = FriendsListResultData
    
    init(original: FriendsListViewModel.SectionModel, items: [FriendsListResultData]) {
        self = original
        self.items = items
    }
}


//MARK: - FriendsListCellDelegate
extension FriendsListViewModel: FriendsListCellDelegate {
    func userSelected(user: FriendsListResultData) {
        processSelectedUser(selectedUser: user)
    }
}

//
//  SearchViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/09.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
//MARK: - Properties
    let disposeBag = DisposeBag()
    let searchRoomResult = PublishRelay<PointerRoomListModel>()
    let searchAccountResult = PublishRelay<[SearchUserListModel]>()

    let tapedRoomResult = PublishRelay<PointerRoomModel>()
    let tapedProfileResult = PublishRelay<SearchUserListModel>()
    
    let presenter = BehaviorRelay<UIViewController?>(value: nil)
    
    private var currentPage = 0
    
    var lastSearchedKeyword = ""
 
//MARK: - In/Out
    struct Input {
        let searchBarTextEditEvent: Observable<String>
    }
    
    struct Output {
        let tapedNextViewController = BehaviorRelay<UIViewController?>(value: nil)
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.searchBarTextEditEvent
            .subscribe { [weak self] text in
                guard let text = text.element,
                      let self = self else { return }
                self.requestRoomList("\(text)")
                self.requestAccountList(word: "\(text)", lastPage: self.currentPage)
                self.lastSearchedKeyword = text
            }
            .disposed(by: disposeBag)
        
        tapedRoomResult
            .subscribe { [weak self] model in
                guard let model = model.element else { return }
                
                if model.voted {
                    let resultVM = ResultViewModel(model.roomId, model.questionId, model.limitedAt)
                    let resultVC = ResultViewController(viewModel: resultVM)
                    resultVC.delegate = self
                    self?.presenter.accept(resultVC)
                } else {
                    let roomVM = RoomViewModel(roomId: model.roomId)
                    let roomVC = RoomViewController(viewModel: roomVM)
                    roomVC.delegate = self
                    output.tapedNextViewController.accept(roomVC)
                }
            }
            .disposed(by: disposeBag)
        
        tapedProfileResult
            .subscribe { model in
                guard let model = model.element else { return }
                
                let viewModel = ProfileViewModel(userId: model.userId)
                let profileVC = ProfileViewController(viewModel: viewModel)
                output.tapedNextViewController.accept(profileVC)
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Functions
    // ToDo - 알림 뷰 중복코드 정리
    func getModifyRoomNameAlert(_ currentName: String, roomId: Int) -> PointerAlert {
        // 0. 취소 Action
        let cancelAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: nil)
        // 1. 확인 Action
        let confirmAction = PointerAlertActionConfig(title: "완료", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansBold(size: 16)) { [weak self] changeTo in
            // 2. 입력한 텍스트로 룸 이름 변경 API 호출
            self?.requestChangeRoomName(changeTo: changeTo, roomId: roomId)
        }
        let customView = CustomTextfieldView(roomName: currentName, withViewHeight: 50)
        let alert = PointerAlert(alertType: .alert, configs: [cancelAction, confirmAction], title: "방 이름 변경", description: "변경할 이름을 입력해주세요", customView: customView)
        return alert
    }

    func getExitRoomAlert(roomId: Int) -> PointerAlert {
        let cancelAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansRegular(size: 15), handler: nil)
        let confirmAction = PointerAlertActionConfig(title: "나가기", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansRegular(size: 15)) { [weak self] _ in
            self?.requestExitRoom(roomId: roomId)
        }
        let alert = PointerAlert(alertType: .alert, configs: [cancelAction, confirmAction], title: "룸 나가기", description: "정말로 나가시겠습니까?")
        return alert
    }
    
    
    
//MARK: - Network
    // 룸 목록 조회
    func requestRoomList(_ word: String) {
        HomeNetworkManager.shared.requestRoomList(word) { [weak self] model, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let data = model?.data {
                self.searchRoomResult.accept(data)
            }
        }
    }
    
    // 유저 검색
    func requestAccountList(word: String, lastPage: Int) {
        FriendSearchNetworkManager.shared.searchUserListRequest(keyword: word, lastPage: lastPage) { [weak self] (model, error) in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let model = model {
                print(model.userList)
                self.searchAccountResult.accept(model.userList)
                self.currentPage = model.currentPage
            }
        }
    }
    
    // 룸 이름 변경 API
    func requestChangeRoomName(changeTo: String?, roomId: Int) {
        guard let roomName = changeTo else { return }
        let input = RoomNameChangeInput(privateRoomNm: roomName, roomId: roomId, userId: TokenManager.getIntUserId())
        HomeNetworkManager.shared.requestRoomNameChange(input: input) { [weak self] response in
            guard let self = self else { return }
            if response.code == "P000" {
                // ToDo - 이녀석을 다시 부르는 방법은 .. ?
                self.requestRoomList(self.lastSearchedKeyword)
            }
        }
    }
    
    // 룸 나가기
    func requestExitRoom(roomId: Int) {
        HomeNetworkManager.shared.requestExitRoom(roomId: roomId) { [weak self] isSuccessed in
            guard let self = self else { return }
            if isSuccessed {
                self.requestRoomList(self.lastSearchedKeyword)
                print("성공")
            } else {
                print("실패")
            }
        }
    }
    
    // 친구 신청, 취소, 수락, 삭제, 거절, 차단, 차단 해제 - 지수님거로 변경 예정
//    func requestChangingFriendRelation(relation: FriendRelation, memberId: Int) {
//        FriendNetworkManager.shared.changeFriendRelationRequest(relation: relation, memberId: memberId) { [weak self] (model, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//            if let model = model {
//                print(model)
//            }
//        }
//    }
}

extension SearchViewModel: ResultViewControllerDelegate {
    func didChangedRoomStateFromResultVC() {
        self.requestRoomList(lastSearchedKeyword)
    }
}


extension SearchViewModel: RoomViewControllerDelegate {
    func didChangedRoomStateFromRoomVC() {
        self.requestRoomList(lastSearchedKeyword)
    }
    
    func tapedPoint(viewController: UIViewController) {
        self.presenter.accept(viewController)
    }
}

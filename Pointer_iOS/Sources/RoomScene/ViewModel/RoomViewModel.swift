//
//  RoomViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa

final class RoomViewModel: ViewModelType {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    let roomResultObservable = PublishRelay<SearchRoomResultModel>()
    
    var roomObservable = BehaviorRelay<[User]>(value: [])
    let allUsersInThisRoom = BehaviorRelay<[User]>(value: [])
    var selectedUsers = BehaviorRelay<[User]>(value: [])
    
    //MARK: - LifeCycle
    init(roomId: Int) {
        // 더미 User들 생성 !
        allUsersInThisRoom.accept(User.getDummyUsers())
        searchRoomRequest(roomId)
    }

    //MARK: - In/Out
    struct Input {
        let hintTextEditEvent: Observable<String>
    }
    
    struct Output {
        var hintTextFieldCountString = BehaviorRelay<String>(value: "0/20")
        var hintTextFieldLimitedString = PublishRelay<String>()
        var selectedUsersJoinedString = BehaviorRelay<String>(value: "")
        var pointButtonValid = PublishRelay<Bool>()
    }
    
    //MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        
        /// 0. 상단에서 Output() 및 필요한 저장값들 선언
        let output = Output()
        let isTextfieldValid = BehaviorSubject(value: false)
        let isUserSelectionEnable = BehaviorSubject(value: false)
        
        /// 1. input으로 들어오는 이벤트 바인딩
        input.hintTextEditEvent
            .subscribe { [weak self] text in
                if let text = text.element,
                   let self = self {
                    /// 1-1 글자수 제한
                    let limitedString = self.hintTextFieldLimitedString(text: text)
                    output.hintTextFieldLimitedString.accept(limitedString)
                    
                    /// 1-2 카운트 string값 방출
                    let textCountString = "\(limitedString.count)/20"
                    output.hintTextFieldCountString.accept(textCountString)

                    /// 1-3 textField Valid 체크
                    if text != "" {
                        isTextfieldValid.onNext(true)
                    } else {
                        isTextfieldValid.onNext(false)
                    }
                }
            }.disposed(by: disposeBag)
        
        /// 2. 선택한 유저 이벤트 바인딩
        self.selectedUsers
            .subscribe { users in
                if let users = users.element {
                    /// 2-1 선택한 유저들을 합친 string 반환
                    let joined = users.map { $0.userName }.joined(separator: " ・ ")
                    output.selectedUsersJoinedString.accept(joined)
                    /// 2-2 유저를 선택한 상태인지? 체크
                    if users.count > 0 {
                        isUserSelectionEnable.onNext(true)
                    } else {
                        isUserSelectionEnable.onNext(false)
                    }
                }
            }.disposed(by: disposeBag)
        
        /// 3. POINT 버튼 활성화 여부 바인딩 - combineLatest
        Observable.combineLatest(isTextfieldValid,
                                 isUserSelectionEnable,
                                 resultSelector: { $0 && $1 }
            ).subscribe {
                output.pointButtonValid.accept($0)
            }.disposed(by: disposeBag)
        
        return output
    }
    
    //MARK: - Functions
    /// 유저 선택
    func selectUser(_ user: User) {
        var currentSelectedUser = selectedUsers.value
        currentSelectedUser.append(user)
        selectedUsers.accept(currentSelectedUser)
        print("DEBUG: \(user.userName) 이 선택됨")
    }
    
    /// 유저 선택 해제
    func deSelectUser(_ selectedUser: User) {
        var currentSelectedUser = selectedUsers.value
        currentSelectedUser.enumerated().forEach { (index, user) in
            // User의 고유값이 같으면 해당 Index 삭제
            if selectedUser.uid == user.uid {
                print("DEBUG: \(user.userID) 선택 해제")
                currentSelectedUser.remove(at: index)
                selectedUsers.accept(currentSelectedUser)
            }
        }
    }
    
    // 선택한 유저 반환
    func getSelectedUser(indexPath: IndexPath) -> User {
        let selectedUser = allUsersInThisRoom.value[indexPath.row]
        return selectedUser
    }
    
    /// SelectedUser 배열 안에 있는 유저인지 확인
    /// reuse 시 체크하는 함수
    func detectSelectedUser(_ selectedUser: User) -> Bool {
        var isSelectedUser = false
        for user in selectedUsers.value {
            if user.uid == selectedUser.uid {
                isSelectedUser = true
                break
            }
        }
        return isSelectedUser
    }
    
    /// POINT 버튼이 valid한지 체크해 반환하는 함수
    func checkPointButtonValid(_ isUserSelectionEnable: Bool, _ isTextfieldValid: Bool) -> Bool {
        if isUserSelectionEnable == true && isTextfieldValid == true {
            return true
        } else {
            return false
        }
    }
    
    /// hintTextField 글자 수 제한 함수
    func hintTextFieldLimitedString(text: String) -> String {
        if text.count > 20 {
            return String(text.prefix(20))
        } else {
            return text
        }
    }
    
    //MARK: - Network
    func searchRoomRequest(_ roomId: Int) {
        // 룸 조회 API
        RoomNetworkManager.shared.searchRoomRequest(roomId)
            .subscribe(onNext: { result in
                self.roomResultObservable.accept(result)
                print("RoomViewModel - searchRoomRequest 데이터: \(result)")
            }, onError: { error in
                print("RoomViewModel - searchRoomRequest 에러: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}

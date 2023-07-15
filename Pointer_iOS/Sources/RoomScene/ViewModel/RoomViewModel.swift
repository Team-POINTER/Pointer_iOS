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
    let roomResultObservable = PublishRelay<SearchQuestionResultData>()
    let roomResultMembersObservable = PublishRelay<[SearchQuestionResultMembers]>()
    var selectedUsers = BehaviorRelay<[SearchQuestionResultMembers]>(value: [])
    
    var roomObservable = BehaviorRelay<[User]>(value: []) //
    let allUsersInThisRoom = BehaviorRelay<[User]>(value: []) // 더미
    
    // 투표용 properties
    var questionId: Int = 0
    var userId = TokenManager.getIntUserId()
    var votedUsers: [Int] = [0]
    var hintString: String = ""
    
    //MARK: - LifeCycle
    init(roomId: Int) {
        // 더미 User들 생성 !
//        allUsersInThisRoom.accept(User.getDummyUsers())
        currentQuestionRequest(roomId)
    }

    //MARK: - In/Out
    struct Input {
        let hintTextEditEvent: Observable<String>
        let pointButtonTapEvent: Observable<Void>
        let inviteButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        var hintTextFieldCountString = BehaviorRelay<String>(value: "0/20")
        var hintTextFieldLimitedString = PublishRelay<String>()
        var selectedUsersJoinedString = BehaviorRelay<String>(value: "")
        var pointButtonValid = PublishRelay<Bool>()
        var pointButtonTap = PublishRelay<UIViewController>()
        var inviteButtonTap = PublishRelay<UIViewController>()
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
                    hintString = limitedString
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
                    let joined = users.map { $0.nickname }.joined(separator: " ・ ")
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
        
        /// 4. POINT 버튼 Tap 시
        input.pointButtonTapEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // selected된 유저의 userId 값만 따로 배열 설정
                self.selectedUsers
                    .subscribe { selectedUsers in
                        if let users = selectedUsers.element {
                            self.votedUsers = users.map { $0.userId }
                        }
                    }
                    .disposed(by: disposeBag)
                
                
                let vote = VoteRequestModel(questionId: self.questionId,
                                            userId: self.userId,
                                            votedUserIds: self.votedUsers,
                                            hint: self.hintString)

                self.voteRequest(vote) { (error, model) in
                    // 서버 연동 실패 시
                    if let error = error {
                        return
                    }
                    
                    // 서버 연동 성공 시
                    if let model = model {
                        output.pointButtonTap.accept(ResultViewController(viewModel: ResultViewModel(self.questionId)))
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.inviteButtonTapEvent
            .subscribe(onNext: { _ in
                print("초대하기 버튼 Tap")
//                output.inviteButtonTap.accept(<#T##event: UIViewController##UIViewController#>)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    //MARK: - Functions
    /// 유저 선택
    func selectUser(_ user: SearchQuestionResultMembers) {
        var currentSelectedUser = selectedUsers.value
        currentSelectedUser.append(user)
        selectedUsers.accept(currentSelectedUser)
        print("DEBUG: \(user.userId) 이 선택됨")
    }
    
    /// 유저 선택 해제
    func deSelectUser(_ selectedUser: SearchQuestionResultMembers) {
        var currentSelectedUser = selectedUsers.value
        currentSelectedUser.enumerated().forEach { (index, user) in
            // User의 고유값이 같으면 해당 Index 삭제
            if selectedUser.userId == user.userId {
                print("DEBUG: \(user.nickname) 선택 해제")
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
    func detectSelectedUser(_ selectedUser: SearchQuestionResultMembers) -> Bool {
        var isSelectedUser = false
        for user in selectedUsers.value {
            if user.userId == selectedUser.userId {
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
//    func searchRoomRequest(_ roomId: Int) {
//        // 룸 조회 API
//        RoomNetworkManager.shared.searchRoomRequest(roomId)
//            .subscribe(onNext: { result in
//                self.roomResultObservable.accept(result)
//                self.roomResultMembersObservable.accept(result.roomMembers)
//                print("RoomViewModel - searchRoomRequest 데이터: \(result)")
//            }, onError: { error in
//                print("RoomViewModel - searchRoomRequest 에러: \(error.localizedDescription)")
//            })
//            .disposed(by: disposeBag)
//    }
    
    func currentQuestionRequest(_ roomId: Int) {
        print("🔥 currentQuestionRequest")
        RoomNetworkManager.shared.currentQuestionRequest(roomId)
            .subscribe(onNext: { [weak self] result in
                self?.roomResultObservable.accept(result)
                self?.roomResultMembersObservable.accept(result.members)
                self?.questionId = result.questionId
                print("🔥RoomViewModel - currentQuestionRequest 데이터: \(result)")
            }, onError: { error in
                print("RoomViewModel - currentQuestionRequest 에러: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func voteRequest(_ voteRequestModel: VoteRequestModel, completion: @escaping(Error?, [VoteResultData]?) -> Void) {
        RoomNetworkManager.shared.voteRequest(voteRequestModel) { (error, model) in
            if let error = error {
                print("RoomViewModel - voteRequest 에러: \(error.localizedDescription)")
                completion(error,nil)
            }
            
            if let model = model {
                print("🔥투표 성공")
                completion(nil, model)
            }
        }
    }
    
}

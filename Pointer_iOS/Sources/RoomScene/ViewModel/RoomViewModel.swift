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
    let roomResultObservable = PublishRelay<SearchRoomResultData>()
    let roomResultMembersObservable = PublishRelay<[SearchRoomMembers]>()
    var selectedUsers = BehaviorRelay<[SearchRoomMembers]>(value: [])
    let dismissRoom = BehaviorRelay<Bool>(value: false)
    
    var roomId: Int
    var limitedAt = ""
    
    // 투표용 properties
    var questionId: Int = 0
    var userId = TokenManager.getIntUserId()
    var votedUsers: [Int] = []
    var hintString: String = ""
    
    //MARK: - LifeCycle
    init(roomId: Int) {
        self.roomId = roomId
        // 더미 User들 생성 !
//        allUsersInThisRoom.accept(User.getDummyUsers())
        searchRoomRequest(roomId)
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
                    self.hintString = limitedString
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
                    let joined = users.map { $0.name }.joined(separator: " ・ ")
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
                    .disposed(by: self.disposeBag)
                
                
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
                        output.pointButtonTap.accept(ResultViewController(viewModel: ResultViewModel(self.roomId, self.questionId, self.limitedAt)))
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
    func selectUser(_ user: SearchRoomMembers) {
        var currentSelectedUser = selectedUsers.value
        currentSelectedUser.append(user)
        selectedUsers.accept(currentSelectedUser)
        print("DEBUG: \(user.name) 이 선택됨")
    }
    
    /// 유저 선택 해제
    func deSelectUser(_ selectedUser: SearchRoomMembers) {
        var currentSelectedUser = selectedUsers.value
        currentSelectedUser.enumerated().forEach { (index, user) in
            // User의 고유값이 같으면 해당 Index 삭제
            if selectedUser.userId == user.userId {
                print("DEBUG: \(user.name) 선택 해제")
                currentSelectedUser.remove(at: index)
                selectedUsers.accept(currentSelectedUser)
            }
        }
    }
    
    /// SelectedUser 배열 안에 있는 유저인지 확인
    /// reuse 시 체크하는 함수
    func detectSelectedUser(_ selectedUser: SearchRoomMembers) -> Bool {
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
    
    //MARK: - Alert
    func getModifyRoomNameAlert(_ currentName: String, roomId: Int) -> PointerAlert {
        // 0. 취소 Action
        let cancelAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: nil)
        // 1. 확인 Action
        let confirmAction = PointerAlertActionConfig(title: "완료", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansBold(size: 16)) { [weak self] changeTo in
            // 2. 입력한 텍스트로 룸 이름 변경 API 호출
            self?.requestChangeRoomName(changeTo: changeTo, roomId: roomId)
        }
        let customView = CustomTextfieldView(roomName: currentName, withViewHeight: 50)
        let alert = PointerAlert(alertType: .alert, configs: [cancelAction, confirmAction], title: "룸 이름 편집", description: "'\(currentName)'의 새로운 이름을 입력하세요", customView: customView)
        return alert
    }
    
    
    func getExitRoomAlert(roomId: Int) -> PointerAlert {
        let cancelAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: nil)
        let confirmAction = PointerAlertActionConfig(title: "나가기", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansBold(size: 16)) { [weak self] _ in
            self?.requestExitRoom(roomId: roomId)
        }
        let alert = PointerAlert(alertType: .alert, configs: [cancelAction, confirmAction], title: "룸 나가기", description: "정말로 나가시겠습니까?")
        return alert
    }
    
    //MARK: - Network
    func searchRoomRequest(_ roomId: Int) {
        // 룸 조회 API
        RoomNetworkManager.shared.searchRoomRequest(roomId)
            .subscribe(onNext: { [weak self] result in
                self?.roomResultObservable.accept(result)
                self?.roomResultMembersObservable.accept(result.roomMembers)
                self?.questionId = result.questionId
                self?.limitedAt = result.limitedAt
                print("🔥 RoomViewModel - searchRoomRequest 데이터: \(result)")
            }, onError: { error in
                print("RoomViewModel - searchRoomRequest 에러: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
//    func currentQuestionRequest(_ roomId: Int) {
//        print("🔥 currentQuestionRequest")
//        RoomNetworkManager.shared.currentQuestionRequest(roomId)
//            .subscribe(onNext: { [weak self] result in
//                self?.roomResultObservable.accept(result)
//                self?.roomResultMembersObservable.accept(result.members)
//                self?.questionId = result.questionId
//                print("🔥RoomViewModel - currentQuestionRequest 데이터: \(result)")
//            }, onError: { error in
//                print("RoomViewModel - currentQuestionRequest 에러: \(error.localizedDescription)")
//            })
//            .disposed(by: disposeBag)
//    }
    
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
    
    // 룸 이름 변경 API
    func requestChangeRoomName(changeTo: String?, roomId: Int) {
        guard let roomName = changeTo else { return }
        let input = RoomNameChangeInput(privateRoomNm: roomName, roomId: roomId, userId: TokenManager.getIntUserId())
        HomeNetworkManager.shared.requestRoomNameChange(input: input) { [weak self] response in
            if response.code == "J000" {
                // ToDo - 이녀석을 다시 부르는 방법은 .. ?
                self?.dismissRoom.accept(true)
            }
        }
    }
    
    // 룸 나가기
    func requestExitRoom(roomId: Int) {
        HomeNetworkManager.shared.requestExitRoom(roomId: roomId) { [weak self] isSuccessed in
            if isSuccessed {
                print("룸 나가기 성공")
                self?.dismissRoom.accept(true)
            } else {
                print("실패")
            }
        }
    }
}

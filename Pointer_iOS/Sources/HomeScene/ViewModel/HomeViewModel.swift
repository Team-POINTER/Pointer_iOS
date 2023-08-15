//
//  HomeViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/12.
//

import UIKit
import RxRelay
import RxSwift
import RxCocoa

class HomeViewModel: ViewModelType {
    
//MARK: - Properties
    var disposeBag = DisposeBag()
    let roomModel = BehaviorRelay<[PointerRoomModel]>(value: [])
    let nextViewController = BehaviorRelay<UIViewController?>(value: nil)
    let expiredToken = BehaviorRelay<Bool>(value: false)
    let network = HomeNetworkManager()

    
//MARK: - In/Out
    struct Input {
        
    }
    
    struct Output {
    
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        requestRoomList()
        return output
    }
    
//MARK: - Helper Function
    func getRoomViewModel(index: Int) -> RoomCellViewModel {
        return RoomCellViewModel(roomModel: roomModel.value[index])
    }
    
    //MARK: - NextViewConfigure
    func pushSingleRoomController(voted: Bool = false, roomId: Int, questionId: Int = 0, limitedAt: String = "") {
        // 룸 투표 여부에 따라
        if voted {
            let resultVC = ResultViewController(viewModel: ResultViewModel(roomId, questionId, limitedAt))
            nextViewController.accept(resultVC)
        } else {
            let roomVC = RoomViewController(viewModel: RoomViewModel(roomId: roomId))
            nextViewController.accept(roomVC)
        }
    }
    

    //MARK: - AlertView
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
    
    
    func getCreateRoomNameAlert() -> PointerAlert {
        let cancelAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: nil)
        let confirmAction = PointerAlertActionConfig(title: "완료", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansBold(size: 16)) { [weak self] changeTo in
            guard let roomName = changeTo else { return }
            self?.requestCreateRoom(roomName: roomName)
        }
        let customView = CustomTextfieldView(roomName: nil, withViewHeight: 50)
        let alert = PointerAlert(alertType: .alert, configs: [cancelAction, confirmAction], title: "룸 이름 설정", description: "새로운 룸의 이름을 입력하세요", customView: customView)
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
    
    //MARK: - API Request
    // ToDo - 이름 최소 조건시 확인 버튼이 안눌리도록
    // ToDo - request 넘기는거 memory leak 나는건가..?
    // ToDo - code 별로 에러처리, 래픽토링
    // RoomList API 호출
    func requestRoomList(handler: (() -> Void)? = nil) {
        let word = ""
        IndicatorManager.shared.show()
        network.requestRoomList { [weak self] model, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let model = model,
                  let self = self else { return }
            
            // 성공한 경우 roomModel에 data 바인딩
            if model.code == RoomRouter.getRoomList(word).successCode {
                guard let data = model.data else { return }
                self.roomModel.accept(data.roomList)
            } else {
                // 실패한 경우 - 현재는 액세스 토큰 만료 경우밖에 없음
                self.requestNewAccessToken()
            }
            IndicatorManager.shared.hide()
            handler?()
        }
    }
    
    // Refresh 토큰으로 Access 토큰 갱신(UserDefaults)
    private func requestNewAccessToken() {
        guard let refresh = TokenManager.getUserRefreshToken() else { return }
        AuthNetworkManager.shared.reissuePost(refresh) { isSuccess in
            // 성공일 경우 룸 리스트 다시 호출하기
            if isSuccess {
                self.requestRoomList()
            } else {
                self.expiredToken.accept(true)
            }
        }
    }
    
    // 룸 이름 변경 API
    func requestChangeRoomName(changeTo: String?, roomId: Int) {
        guard let roomName = changeTo else { return }
        let input = RoomNameChangeInput(privateRoomNm: roomName, roomId: roomId, userId: TokenManager.getIntUserId())
        network.requestRoomNameChange(input: input) { [weak self] response in
            if response.code == "J000" {
                // ToDo - 이녀석을 다시 부르는 방법은 .. ?
                self?.requestRoomList()
            }
        }
    }
    
    // 룸 생성
    func requestCreateRoom(roomName: String) {
        network.requestCreateRoom(roomName: roomName) { [weak self] roomId in
            if let id = roomId {
                self?.pushSingleRoomController(roomId: id)
                self?.requestRoomList()
            } else {
                // 에러일 때
            }
        }
    }
    
    // 룸 나가기
    func requestExitRoom(roomId: Int) {
        network.requestExitRoom(roomId: roomId) { [weak self] isSuccessed in
            if isSuccessed {
                self?.requestRoomList()
                print("성공")
            } else {
                print("실패")
            }
        }
    }
}

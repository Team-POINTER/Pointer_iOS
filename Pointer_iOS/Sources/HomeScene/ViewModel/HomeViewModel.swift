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
    
    func requestRoomList() {
        network.requestRoomList { [weak self] models, error in
            if let error = error {
                print(error)
                return
            }
            
            if let models = models {
                self?.roomModel.accept(models)
            }
        }
    }
    
    //MARK: - NextViewConfigure
    func pushSingleRoomController(roomId: Int) {
        let viewController = RoomViewController(viewModel: RoomViewModel(roomId: roomId))
        nextViewController.accept(viewController)
    }
    
    //MARK: - API Request
    // ToDo - 이름 최소 조건시 확인 버튼이 안눌리도록
    // ToDo - request 넘기는거 memory leak 나는건가..?
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
        let customView = CustomTextfieldView(roomName: "", withViewHeight: 50)
        let alert = PointerAlert(alertType: .alert, configs: [cancelAction, confirmAction], title: "룸 이름 설정", description: "새로운 룸의 이름을 입력하세요", customView: customView)
        return alert
    }
    
    // ToDo - code 별로 에러처리, 래픽토링
    func requestChangeRoomName(changeTo: String?, roomId: Int) {
        guard let roomName = changeTo else { return }
        let input = RoomNameChangeInput(privateRoomNm: roomName, roomId: roomId, userId: TokenManager.getIntUserId())
        network.requestRoomNameChange(input: input) { [weak self] response in
            if response.code == "J000" {
                print("변경 성공")
                // ToDo - 이녀석을 다시 부르는 방법은 .. ?
                self?.requestRoomList()
            }
        }
    }
    
    func requestCreateRoom(roomName: String) {
        network.requestCreateRoom(roomName: roomName) { [weak self] roomId in
            if let id = roomId {
                self?.pushSingleRoomController(roomId: id)
            } else {
                // 에러일 때
            }
        }
    }
}

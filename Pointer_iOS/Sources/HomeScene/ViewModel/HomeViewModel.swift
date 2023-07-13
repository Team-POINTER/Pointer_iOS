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
    let network = HomeNetworkManager()
//    private let homeNextworkProtocol: HomeNetworkProtocol
//
//    init( homeNextworkProtocol: HomeNetworkProtocol) {
//        self.homeNextworkProtocol = homeNextworkProtocol
//    }
    
//MARK: - In/Out
    struct Input {
        
    }
    
    struct Output {
        
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        network.requestRoomList()
            .subscribe { [weak self] models in
                self?.roomModel.accept(models)
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Helper Function
    func getRoomViewModel(index: Int) -> RoomCellViewModel {
        return RoomCellViewModel(roomModel: roomModel.value[index])
    }
}

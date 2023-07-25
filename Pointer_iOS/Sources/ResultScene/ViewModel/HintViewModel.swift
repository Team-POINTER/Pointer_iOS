//
//  HintViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/15.
//

import UIKit
import RxSwift
import RxCocoa

class HintViewModel: ViewModelType{
//MARK: - Properties
    let disposeBag = DisposeBag()
    let showHintObservable = PublishRelay<ShowHintResultData>()
    
    var roomName = ""
    var question = ""
    var userName = ""
    
//MARK: - Init
    init(questionId: Int, roomName: String, question: String, userName: String) {
        showHintRequest(questionId)
        self.roomName = roomName
        self.question = question
        self.userName = userName
    }
    
//MARK: - In/Out
    struct Input {
        
    }
    
    struct Output {
        
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        return output
    }
    
//MARK: - Alert
    func alertRequest() {

    }

    
//MARK: - Network
    func showHintRequest(_ questionId: Int) {
        ResultNetworkManager.shared.showHintRequest(questionId)
            .subscribe(onNext: { [weak self] data in
                self?.showHintObservable.accept(data)
            }, onError: { error in
                print("HintViewModel - showHintRequest Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}

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
    let dismissHintView = BehaviorRelay<Bool>(value: false)
    
    let roomName: String
    let userName: String
    let question: String
    
    let roomId: Int
    let questionId: Int
    
    enum DeleteHintCode: String, CaseIterable {
        case success = "K006"
        case fail = "K004"
    }
    
//MARK: - Init
    init(roomName: String, userName: String, question: String, roomId: Int , questionId: Int) {
        self.roomName = roomName
        self.userName = userName
        self.question = question
        
        self.roomId = roomId
        self.questionId = questionId
        showHintRequest(questionId)
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
    
    func deleteHintRequest(voterId: Int) {
        let model = DeleteHintRequestModel(questionId: questionId, voterId: voterId)
        
        ResultNetworkManager.shared.deleteHintRequest(model) { [weak self] (error, model) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let model = model {
                if model.code == DeleteHintCode.success.rawValue {
                    self?.dismissHintView.accept(true)
                }
                if model.code == DeleteHintCode.fail.rawValue {
                    print("DEBUG: 힌트 삭제 실패")
                }
            }
        }
    }
}

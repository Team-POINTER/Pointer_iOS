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
    
//MARK: - Init
    init(questionId: Int) {
        showHintRequest(questionId)
    }
    
//MARK: - In/Out
    struct Input {
        
    }
    
    struct Output {
        
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        
        
        return Output()
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

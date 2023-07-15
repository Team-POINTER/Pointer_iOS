//
//  MyResultViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/25.
//

import UIKit
import RxSwift
import RxCocoa

class MyResultViewModel: ViewModelType{
//MARK: - Properties
    let disposeBag = DisposeBag()
    var myResultObservable = PublishRelay<[TotalQuestionResultData]>()
    
//MARK: - Init
    init(roomId: Int) {
        totalQuestionRequest(roomId)
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
    func totalQuestionRequest(_ roomId: Int) {
        ResultNetworkManager.shared.totalQuestionRequest(roomId)
            .subscribe(onNext: { data in
                self.myResultObservable.accept(data)
            }, onError: { error in
                print("MyResultViewModel - totalQuestionRequest Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}

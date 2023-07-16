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
    var questId = 0 {
        didSet {
            print("questId = \(questId)")
        }
    }
    
//MARK: - Init
    init(roomId: Int) {
        totalQuestionRequest(roomId)
    }
    
//MARK: - In/Out
    struct Input {
        let hintTableViewItemSelected: Observable<IndexPath>
        let hintTableViewModelSelected: Observable<TotalQuestionResultData>
    }
    
    struct Output {
        let hintTableViewSelected = PublishRelay<UIViewController>()
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
// - tableView cell tapped
        Observable
            .zip(input.hintTableViewItemSelected, input.hintTableViewModelSelected)
            .bind { indexPath, model in
                print("myResultViewModel - tap: \(indexPath)")
                output.hintTableViewSelected.accept(HintViewController(viewModel: HintViewModel(questionId: model.questionId)))
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Functions

    
    
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

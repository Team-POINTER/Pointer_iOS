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
    
    let userName: String
    let roomName: String
    let roomId: Int
    
//MARK: - Init
    init(_ roomId: Int, _ userName: String, _ roomName: String) {
        self.userName = userName
        self.roomName = roomName
        self.roomId = roomId
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
            .bind { [weak self] indexPath, model in
                guard let self = self else { return }
                let viewModel = HintViewModel(roomName: self.roomName,
                                              userName: self.userName,
                                              question: model.question,
                                              roomId: self.roomId,
                                              questionId: model.questionId)
                
                output.hintTableViewSelected.accept(HintViewController(viewModel: viewModel))
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

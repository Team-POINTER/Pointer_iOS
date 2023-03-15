//
//  RoomViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

struct RoomViewModel {
    
    let hintTextObservable = BehaviorRelay<String>(value: "")
    
    let currentLength: Signal<String>
    let isEditable: Signal<Bool>
    
    // 글자제한
    init(maxNumber: Int) {
        let hintTextObservable = hintTextObservable.share()
        
        currentLength = hintTextObservable
            .map{ $0.count }
            .map({ number in
                let currentNumber = number > 20 ? number - 1 : number
                return "\(currentNumber)/20"
            })
            .asSignal(onErrorJustReturn: "0/20")
        
        isEditable = hintTextObservable
            .map { $0.count <= 20 }
            .asSignal(onErrorJustReturn: false)
    }
    
    
}

//let hintTextOver = BehaviorRelay<Bool>(value: false)
//let starCheck = BehaviorRelay<Bool>(value: false)


//    init(hiddenCheck : Bool) {
//        let hintTextObservable = hintTextOver.share()
//        let starHiddenObservable = starHidden.share()
//
//        textCheck = hintTextObservable
//            .map{ $0.count > 0 }
//            .asSignal(onErrorJustReturn: false)
//
//
//    }
    
    

//private let roomModel = RoomModel
//
//struct Input {
//    let hintTextDidEditEvent: Observable<String>
//    let peopleDidTapEvent: Observable<Void>
//    let pointButtonActive: Observable<Bool>
//    let pointButtonTapEvent: Observable<Void>
//    let inviteButtonTapEvent: Observable<Void>
//}
//
//struct Output {
//    let hintText = BehaviorRelay<String>(value: "")
//    let pointButtonEnable = BehaviorRelay<Bool>(value: false)
//}
//
//
//init() {
//}
//
//func transform(from input: Input, disposeBag: DisposeBag) -> Output {
//    self.configureInput(input, disposeBag: disposeBag)
//    return ceateOutput(input, disposeBag: disposeBag)
//}
//
//private func configureInput(_ input: Input, disposeBag: DisposeBag) {
//    input.hintTextDidEditEvent
//
//        .subscribe(onNext: { [weak self] hintText in
//            self?.roomModel.hintText
//        })
//        .disposed(by: disposeBag)
//
//
//}
//
//private func ceateOutput(from input: Input, disposeBag: DisposeBag) -> Output {
//    let output = Output()
//
//    self.roomModel.hintText
//        .subscribe(onNext: { [weak self] hintText in
//            output.hintText.accept(self?.roomModel.hintText)
//        }).dispose()
//}

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

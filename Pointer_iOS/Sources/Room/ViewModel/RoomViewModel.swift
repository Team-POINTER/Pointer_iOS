//
//  RoomViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa

protocol RoomViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}


class RoomViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    
    let disposeBag = DisposeBag()
    
    var roomObservable = BehaviorRelay<[RoomModel]>(value: [])
    
    
    lazy var hintTextFieldText = BehaviorRelay<String>(value: "")
    lazy var hintTextEdit = BehaviorRelay<Bool>(value: false)
    lazy var peopleCheck = BehaviorRelay<Bool>(value: false)
    lazy var pointButtonEnable = BehaviorRelay<Bool>(value: false)
//    var pointButtonTap: BehaviorRelay<Void>
    

   
 
    
    
    init() {
        
        let people: [RoomModel] = [
                    RoomModel(name: "박씨", isHidden: true),
                    RoomModel(name: "김씨", isHidden: true),
                    RoomModel(name: "냠남", isHidden: true),
                    RoomModel(name: "최씨", isHidden: true),
                    RoomModel(name: "언씨", isHidden: true),
                    RoomModel(name: "오씨", isHidden: true)
        ]
        
        self.roomObservable.accept(people)
    }


    func binding() {
        
        hintTextFieldText
            .map { $0 != nil }
            .subscribe(onNext: { bool in
                self.hintTextEdit.accept(bool)
            }).disposed(by: disposeBag)
        
        
//        var isValid: Observable<Bool> {
       //        return Observable.combineLatest(hintTextFieldText, buttonSelect)
       //            .map{ text, buttonSelect in
       //                print("\(text)")
       //                return !text.isEmpty && tableViewCellTaped
       //            }
       //    }
    }
    
}


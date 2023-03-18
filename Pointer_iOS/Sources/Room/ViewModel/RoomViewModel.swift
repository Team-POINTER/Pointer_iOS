//
//  RoomViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa

class RoomViewModel {
    
    var roomObservable = BehaviorRelay<[RoomModel]>(value: [])
    
    
    lazy var hintTextFieldText = BehaviorRelay<String>(value: "")
    lazy var hintTextEdit = BehaviorRelay<Bool>(value: false)
    lazy var peopleCheck = BehaviorRelay<Bool>(value: false)
    lazy var pointButtonEnable = BehaviorRelay<Bool>(value: false)
    

   
 
    
    
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

        
//        var isValid: Observable<Bool> {
       //        return Observable.combineLatest(hintTextFieldText, buttonSelect)
       //            .map{ text, buttonSelect in
       //                print("\(text)")
       //                return !text.isEmpty && tableViewCellTaped
       //            }
       //    }
    }
    
}


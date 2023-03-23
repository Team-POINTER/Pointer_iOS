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
    

final class RoomViewModel: RoomViewModelType {
    
    
    let disposeBag = DisposeBag()
    var roomObservable = BehaviorRelay<[RoomModel]>(value: [])
    var cellIndexs = BehaviorRelay<[Int]>(value: [])
    
    
    
    struct Input {
        let hintTextEditEvent: Observable<String>
    }
    
    struct Output {
        let hintTextFieldCount: Observable<String>
        let hintTextValid: Observable<String>
        let pointButtonValid: Observable<Bool>
    }
    
    
    func transform(input: Input) -> Output {
        
        let hintText = input.hintTextEditEvent
            .map{ "\($0.count)/20" }
        
        let hintValid = input.hintTextEditEvent
            .map{ str -> String in
                if str.count > 20 {
                    return String(str.prefix(20))
                } else {
                    return str
                }
            }
        
        let textBool = input.hintTextEditEvent
            .map(textValid)

        let arrBool = cellIndexs.map(arrayValid)
        
        let pointButtonValid = Observable.combineLatest(textBool, arrBool, resultSelector: { $0 && $1 })

        return Output(hintTextFieldCount: hintText, hintTextValid: hintValid, pointButtonValid: pointButtonValid)
    }

    func addIndex(_ index: Int) {
        var value = self.cellIndexs.value
        value.append(index)
        value.sort()
        self.cellIndexs.accept(value)
        print("index = \(value)")
    }
    
    func deleteIndex(_ index: Int) {
        var value = self.cellIndexs.value
        if let selectIndex = value.lastIndex(of: index) {
            value.remove(at: selectIndex)
        }
        self.cellIndexs.accept(value)
        print("index = \(value)")
    }
 
    private func textValid(_ text: String) -> Bool {
        return text.count > 0
    }
    
    private func arrayValid(_ arr: [Int]) -> Bool {
        return arr.count > 0
    }
 
    func pointButtonTaped() {
        print("point버튼 Tap")
    }
}

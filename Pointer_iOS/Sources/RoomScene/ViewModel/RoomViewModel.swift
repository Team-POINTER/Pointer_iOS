//
//  RoomViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa

final class RoomViewModel: ViewModelType {
    
    
    let disposeBag = DisposeBag()
    var roomObservable = BehaviorRelay<[RoomModel]>(value: [])
    var isSelectedCell = [Int]()
    var cellNames = BehaviorRelay<[String]>(value: [])
    
    
    
    
    struct Input {
        let hintTextEditEvent: Observable<String>
        
    }
    
    struct Output {
        let hintTextFieldCount: Observable<String>
        let hintTextValid: Observable<String>
        let selectPeople: Observable<String>
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

        let arrBool = cellNames.map(arrayValid)
        
        let people = cellNames.map{ $0.joined(separator: " · ") }
        
        
        let pointButtonValid = Observable.combineLatest(textBool, arrBool, resultSelector: { $0 && $1 })

        return Output(hintTextFieldCount: hintText, hintTextValid: hintValid, selectPeople: people, pointButtonValid: pointButtonValid)
    }
    
    func addIndex(_ index: Int) {
        self.isSelectedCell.append(index)
        print(self.isSelectedCell)
    }
    
    func deleteIndex(_ index: Int) {
        if let delIndex = self.isSelectedCell.firstIndex(of: index) {
            self.isSelectedCell.remove(at: delIndex)
            print(self.isSelectedCell)
        }
        
    }
    
    
    func addName(_ name: String) {
        var value = self.cellNames.value
        value.append(name)
        self.cellNames.accept(value)
        print("name = \(value)")
    }
    
    func deleteName(_ name: String) {
        var value = self.cellNames.value
        if let selectName = value.lastIndex(of: name) {
            value.remove(at: selectName)
        }
        self.cellNames.accept (value)
        print("name = \(value)")
    }
    
    
 
    private func textValid(_ text: String) -> Bool {
        return text.count > 0
    }
    
    private func arrayValid(_ arr: [String]) -> Bool {
        return arr.count > 0
    }
    
    private func peopleArrayValid(_ arr: [String]) -> Bool {
        return arr.count > 0
    }
    
}

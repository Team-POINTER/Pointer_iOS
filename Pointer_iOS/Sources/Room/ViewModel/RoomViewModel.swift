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
    var totalClickCount = 0
    var cellChecked = [0,0,0,0,0,0,0,0,0,0]
    
    
    struct Input {
        let hintTextEditEvent: Observable<String>
//        let cellCheckedEvent: Observable<Int>
        let pointButtonTapedEvent: Observable<Void>
    }
    
    struct Output {
        let hintTextFieldCount: Observable<String>
        let hintTextValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let cellTapValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let pointButtonTap: Observable<Void>
    }
    
    
    func transform(input: Input) -> Output {
        
        let hintText = input.hintTextEditEvent
            .map{ "\($0.count)/20" }
        
        let hintValid = input.hintTextEditEvent
            .map(hintTextCheck)
        
//         nameTapValid의 배열 중 1이 포함 될 시 true
        let nameTapValid = Observable.just(totalClickCount)
            .map(nameTapCheck)
        
        let pointTap = input.pointButtonTapedEvent
        // 입력된 텍스트값, cellChekced 데이터 보내기

        // 값이 (0,0,0,0) 에서 (0,0,0,1)이 변경되었을 때
        return Output(hintTextFieldCount: hintText, pointButtonTap: pointTap, cellTapValid: nameTapValid, pointButtonTap: pointTap)
    }

    private func hintTextCheck(_ text: String) -> Bool {
        return text.count > 0
    }
    
    private func nameTapCheck(_ num: Int) -> Bool {
        return num > 0
    }
    
}


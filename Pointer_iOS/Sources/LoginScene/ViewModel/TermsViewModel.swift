//
//  TermsViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/27.
//

import Foundation
import RxSwift
import RxCocoa

class TermsViewModel: ViewModelType {
    
    var loginNickname = ""
    var loginAccessToken = ""
    
    struct Input {
        let allAllowTapEvent: Observable<Void>
        let overAgeAllowTapEvent: Observable<Void>
        let serviceAllowTapEvent: Observable<Void>
        let privateInfoAllowTapEvent: Observable<Void>
        let marketingInfoAllowTapEvent: Observable<Void>
        let nextButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        var allAllow: Observable<Bool>
        var overAgeAllow: Observable<Bool>
        var serviceAllow: Observable<Bool>
        var privateInfoAllow: Observable<Bool>
        var marketingInfoAllow: Observable<Bool>
        var nextButtonValid: Observable<Bool>
        var nextButtonTap: Observable<Void>

    }
    
    func transform(input: Input) -> Output {
        
        let allAllow = input.allAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }
        
        let overAllow = input.overAgeAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }
        
        let serviceAllow = input.serviceAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }
        
        let privateInfoAllow = input.privateInfoAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }
        
        let marketingInfoAllow = input.marketingInfoAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }
        
        let nextButtonValid = Observable.combineLatest(serviceAllow, privateInfoAllow, resultSelector: { $0 && $1 })
        
        let nextButtonTap = input.nextButtonTapEvent
            .map(nextBtnTap)
       
        return Output(allAllow: allAllow, overAgeAllow: overAllow, serviceAllow: serviceAllow, privateInfoAllow: privateInfoAllow, marketingInfoAllow: marketingInfoAllow, nextButtonValid: nextButtonValid, nextButtonTap: nextButtonTap)
    }


    func nextBtnTap() {
        print("버튼 활성화 시 실행할 함수")
    }
    
}

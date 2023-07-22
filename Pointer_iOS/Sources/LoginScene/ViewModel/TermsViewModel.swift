//
//  TermsViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/27.
//

import RxSwift
import RxCocoa
import UIKit

class TermsViewModel: ViewModelType {
    
    let disposeBag = DisposeBag()
    let authResultModel: AuthResultModel
    
    var serviceAgree = 0
    var serviceAge = 0
    var marketing = 0
    
    init(authResultModel: AuthResultModel) {
        self.authResultModel = authResultModel
    }
    
    struct Input {
        let allAllowTapEvent: Observable<Void>
        let overAgeAllowTapEvent: Observable<Void>
        let serviceAllowTapEvent: Observable<Void>
        let privateInfoAllowTapEvent: Observable<Void>
        let marketingInfoAllowTapEvent: Observable<Void>
        let nextButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        var allAllow = BehaviorRelay<Bool>(value: false)
        var overAgeAllow = BehaviorRelay<Bool>(value: false)
        var serviceAllow = BehaviorRelay<Bool>(value: false)
        var privateInfoAllow = BehaviorRelay<Bool>(value: false)
        var marketingInfoAllow = BehaviorRelay<Bool>(value: false)
        var nextButtonValid = BehaviorRelay<Bool>(value: false)
        var nextButtonTap = PublishRelay<UIViewController>()

    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.allAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }.bind(to: output.allAllow)
            .disposed(by: disposeBag)
        
        input.overAgeAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }.bind(to: output.overAgeAllow)
            .disposed(by: disposeBag)
        
        input.serviceAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }.bind(to: output.serviceAllow)
            .disposed(by: disposeBag)
        
        input.privateInfoAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }.bind(to: output.privateInfoAllow)
            .disposed(by: disposeBag)
        
        input.marketingInfoAllowTapEvent
            .scan(false) { lastValue, _ in
                return !lastValue
            }.bind(to: output.marketingInfoAllow)
            .disposed(by: disposeBag)
        
        output.allAllow
            .subscribe(onNext: { b in
                output.overAgeAllow.accept(b)
                output.serviceAllow.accept(b)
                output.privateInfoAllow.accept(b)
                output.marketingInfoAllow.accept(b)
                output.nextButtonValid.accept(b)
            })
            .disposed(by: disposeBag)
        
        output.overAgeAllow
            .subscribe(onNext: { [weak self] b in
                b ? (self?.serviceAge = 1) : (self?.serviceAgree = 0)
            })
            .disposed(by: disposeBag)
        
        output.marketingInfoAllow
            .subscribe(onNext: { [weak self] b in
                b ? (self?.marketing = 1) : (self?.marketing = 0)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.serviceAllow, output.privateInfoAllow, resultSelector: { $0 && $1 })
            .subscribe(onNext: { [weak self] b in
                b ? (self?.serviceAgree = 1) : (self?.serviceAgree = 0)
                output.nextButtonValid.accept(b)
            })
            .disposed(by: disposeBag)
        
        input.nextButtonTapEvent
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                
                let createUserIdViewModel = CreateUserIDViewModel(authResultModel: self.authResultModel)
                let createUserIdViewController = CreateUserIDViewController(viewModel: createUserIdViewModel)
                output.nextButtonTap.accept(createUserIdViewController)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    
}

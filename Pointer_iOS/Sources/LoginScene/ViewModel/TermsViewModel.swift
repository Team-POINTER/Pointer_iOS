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
            .withLatestFrom(output.allAllow)
            .bind { b in
                output.allAllow.accept(!b)
                output.overAgeAllow.accept(!b)
                output.serviceAllow.accept(!b)
                output.privateInfoAllow.accept(!b)
                output.marketingInfoAllow.accept(!b)
            }
            .disposed(by: disposeBag)
        
        input.overAgeAllowTapEvent
            .withLatestFrom(output.overAgeAllow)
            .bind { b in
                output.overAgeAllow.accept(!b)
            }
            .disposed(by: disposeBag)
        
        input.serviceAllowTapEvent
            .withLatestFrom(output.serviceAllow)
            .bind { b in
                output.serviceAllow.accept(!b)
            }
            .disposed(by: disposeBag)
        
        input.privateInfoAllowTapEvent
            .withLatestFrom(output.privateInfoAllow)
            .bind { b in
                output.privateInfoAllow.accept(!b)
            }
            .disposed(by: disposeBag)
        
        input.marketingInfoAllowTapEvent
            .withLatestFrom(output.marketingInfoAllow)
            .bind { b in
                output.marketingInfoAllow.accept(!b)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.overAgeAllow, output.serviceAllow, output.privateInfoAllow, output.marketingInfoAllow)
            .map({ (b1, b2, b3, b4) in
                return (b1, b2, b3, b4)
            })
            .subscribe(onNext: { b1, b2, b3, b4 in
                if b1 && b2 && b3 && b4 {
                    output.allAllow.accept(true)
                } else {
                    output.allAllow.accept(false)
                }
                if b1 && b2 && b3 {
                    output.nextButtonValid.accept(true)
                } else {
                    output.nextButtonValid.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        input.nextButtonTapEvent
            .withLatestFrom(output.marketingInfoAllow)
            .subscribe(onNext: { [weak self] b in
                guard let self = self,
                      let accessToken = self.authResultModel.tokenDto?.accessToken else { return }
                let marketingBool = (b == true ? 1 : 0)
                
                let authAgreeInputModel = AuthAgreeInputModel(serviceAgree: 1,
                                                              serviceAge: 1,
                                                              marketing: marketingBool)
                
                self.requestNextViewController(model: authAgreeInputModel, accessToken: accessToken) { vc in
                    output.nextButtonTap.accept(vc)
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func requestNextViewController(model: AuthAgreeInputModel, accessToken: String, completion: @escaping(UIViewController) -> Void) {
        AuthNetworkManager.shared.agreePost(model, accessToken) { authResultModel in
            if authResultModel.code == LoginResultType.serviceAgreeUser.rawValue {
                let createUserIdViewModel = CreateUserIDViewModel(authResultModel: self.authResultModel)
                let createUserIdViewController = CreateUserIDViewController(viewModel: createUserIdViewModel)
                completion(createUserIdViewController)
            } else {
                print("약관동의하지 않았습니다. 다시 확인해주세요.")
            }
        }
    }
}

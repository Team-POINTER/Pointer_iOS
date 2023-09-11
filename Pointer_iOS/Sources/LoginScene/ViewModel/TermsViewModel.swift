//
//  TermsViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/27.
//

import RxSwift
import RxCocoa
import UIKit
import SafariServices

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
        let showServiceTermTapEvent: Observable<Void>
        let privateInfoAllowTapEvent: Observable<Void>
        let showPrivateInfoTermTapEvent: Observable<Void>
        let marketingInfoAllowTapEvent: Observable<Void>
        let showMarketingInfoTermTapEvent: Observable<Void>
        let nextButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let allAllow = BehaviorRelay<Bool>(value: false)
        let overAgeAllow = BehaviorRelay<Bool>(value: false)
        let serviceAllow = BehaviorRelay<Bool>(value: false)
        let privateInfoAllow = BehaviorRelay<Bool>(value: false)
        let marketingInfoAllow = BehaviorRelay<Bool>(value: false)
        let nextButtonValid = BehaviorRelay<Bool>(value: false)
        let presentNextViewController = PublishRelay<UIViewController>()
        let nextButtonTap = PublishRelay<UIViewController>()

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
        
        input.showServiceTermTapEvent
            .subscribe { _ in
                guard let url = URL(string: "https://pointer2024.notion.site/d55d0a2334d549e9a17477bc6ade3bb0?pvs=4") else { return }
                let vc = SFSafariViewController(url: url)
                output.presentNextViewController.accept(vc)
            }
            .disposed(by: disposeBag)
        
        input.showPrivateInfoTermTapEvent
            .subscribe { _ in
                guard let url = URL(string: "https://pointer2024.notion.site/4936ea14737f44018b2d798db4e64d0a?pvs=4") else { return }
                let vc = SFSafariViewController(url: url)
                output.presentNextViewController.accept(vc)
            }
            .disposed(by: disposeBag)
        
        input.showMarketingInfoTermTapEvent
            .subscribe { _ in
                guard let url = URL(string: "https://pointer2024.notion.site/b041b9004cb94648b1c3f1f9adc4ef67") else { return }
                let vc = SFSafariViewController(url: url)
                output.presentNextViewController.accept(vc)
            }
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

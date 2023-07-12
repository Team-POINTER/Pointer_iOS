//
//  CreateUserIDViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/01.
//

import UIKit
import RxSwift
import RxCocoa

class CreateUserIDViewModel: ViewModelType {
    
//MARK: - Properties
    
    var disposeBag = DisposeBag()
    let authResultModel: AuthResultModel
    
    init(authResultModel: AuthResultModel) {
        self.authResultModel = authResultModel
    }

//MARK: - In/Out
    struct Input {
        let idTextFieldEditEvent: Observable<String>
        let idDoubleCheckButtonTapEvent: Observable<Void>
        let nextButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        var idTextFieldCountString = BehaviorRelay<String>(value: "0/20")
        var idTextFieldLimitedString = PublishRelay<String>()
        var idTextFieldValidString = BehaviorRelay<Bool>(value: false)
        var duplicatedIdCheck = BehaviorRelay<Bool>(value: false)
        var userNoticeString = BehaviorRelay<Int>(value: 0)
        var nextButtonValid = BehaviorRelay<Bool>(value: false)
        var nextButtonTap = PublishRelay<UIViewController>()
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.idTextFieldEditEvent
            .subscribe { [weak self] text in
                if let text = text.element,
                   let self = self {
                    /// 글자수 30자 제한
                    let limitedString = self.hintTextFieldLimitedString(text: text)
                    output.idTextFieldLimitedString.accept(limitedString)
                    
                    /// 제한된 글자수 카운트
                    let textCountString = "\(limitedString.count)/30"
                    output.idTextFieldCountString.accept(textCountString)
                    
                    /// 정규표현식 제한
                    let validString = self.isValidInputString(limitedString)
                    output.idTextFieldValidString.accept(validString)
                    
                    if validString {
                        // 유효성 O
                        output.userNoticeString.accept(1)
                    } else {
                        // 유효성 X
                        output.userNoticeString.accept(2)
                    }
                    
                    if limitedString == "" {
                        output.userNoticeString.accept(0)
                    }
                    
                    output.nextButtonValid.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.idDoubleCheckButtonTapEvent
            .withLatestFrom(output.idTextFieldLimitedString)
            .subscribe(onNext: { [weak self] text in
                if let self = self {
                    let authIdInput = AuthIdInputModel(userId: self.authResultModel.userId, id: text)
                    AuthNetworkManager.shared.idCheckPost(authIdInput) { authIdResultModel, loginResultType in
                        if loginResultType == LoginResultType.duplicatedId {
                            // ID 중복 시
                            output.duplicatedIdCheck.accept(false)
                            output.userNoticeString.accept(3)
                        }
                        if loginResultType == LoginResultType.doubleCheck {
                            // 중복 확인 성공 시
                            output.duplicatedIdCheck.accept(true)
                            output.userNoticeString.accept(4)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 유효성 & 중복 확인 시 버튼 활성화
        Observable.combineLatest(output.idTextFieldValidString, output.duplicatedIdCheck, resultSelector: { $0 && $1 })
            .subscribe(onNext: { b in
                output.nextButtonValid.accept(b)
            })
            .disposed(by: disposeBag)
        
        input.nextButtonTapEvent
            .withLatestFrom(output.idTextFieldLimitedString)
            .subscribe(onNext: { [weak self] text in
                if let self = self {
                    let authIdInput = AuthIdInputModel(userId: self.authResultModel.userId, id: text)
                    AuthNetworkManager.shared.idSavePost(authIdInput) { authIdResultModel, loginResultType in
                        if loginResultType == LoginResultType.saveId {
                            // ToDo - 추후 토큰으로 교체요
                            guard let userID = authIdResultModel.userId else { return }
                            self.saveTokenInDevice(string: String(userID))
                            output.nextButtonTap.accept(BaseTabBarController())
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Helper Function
    func saveTokenInDevice(string: String?) {
        if let token = string {
            TokenManager.saveUserToken(token: token)
        }
    }
    
    // idTextField 글자 수 제한 함수
    func hintTextFieldLimitedString(text: String) -> String {
        if text.count > 30 {
            return String(text.prefix(30))
        } else {
            return text
        }
    }
    
    // idTextField 정규표현식 제한 - 영문, 숫자 및 특수문자 . 과 _
    func isValidInputString(_ input: String) -> Bool {
        let pattern = "^[a-zA-Z0-9._]+$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        let matches = regex.matches(in: input, range: range)
        return !matches.isEmpty
    }
}

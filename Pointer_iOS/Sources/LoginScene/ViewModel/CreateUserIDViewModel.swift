//
//  CreateUserIDViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/01.
//

import UIKit
import RxSwift
import RxCocoa

enum IdCheckStyle: CaseIterable {
    case none
    case check
    case unformed
    case duplicated
    case avaliable
    
    var description: String {
        switch self {
        case .none: return ""
        case .check: return "중복 확인해주세요."
        case .unformed: return "형식에 어긋난 아이디입니다."
        case .duplicated: return "중복되는 ID가 있습니다."
        case .avaliable: return "사용 가능한 ID 입니다."
        }
    }
    
    var fontColor: UIColor {
        switch self {
        case .none:
            return UIColor.clear
        case .check:
            return UIColor.inactiveGray
        case .unformed:
            return UIColor.pointerRed
        case .duplicated:
            return UIColor.pointerRed
        case .avaliable:
            return UIColor.green
        }
    }
}

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
        var userNoticeString = BehaviorRelay<IdCheckStyle>(value: .none)
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
                        output.userNoticeString.accept(.check)
                    } else {
                        // 유효성 X
                        output.userNoticeString.accept(.unformed)
                    }
                    
                    if limitedString == "" {
                        output.userNoticeString.accept(.none)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // 입력 값이 바뀌면 nextButton 비활성화
        output.idTextFieldLimitedString
            .subscribe { _ in
                output.nextButtonValid.accept(false)
            }
            .disposed(by: disposeBag)
        
        input.idDoubleCheckButtonTapEvent
            .withLatestFrom(output.idTextFieldLimitedString)
            .subscribe(onNext: { [weak self] text in
                if let self = self {
                    guard let userId = self.authResultModel.tokenDto?.userId else { return }
                    guard let accessToken = self.authResultModel.tokenDto?.accessToken else { return }
                    let authCheckIdInput = AuthCheckIdInputModel(userId: userId, id: text)
                    AuthNetworkManager.shared.idCheckPost(authCheckIdInput, accessToken) { authIdResultModel, loginResultType in
                        if loginResultType == LoginResultType.duplicatedId {
                            // ID 중복 시
                            output.duplicatedIdCheck.accept(false)
                            output.userNoticeString.accept(.duplicated)
                        }
                        if loginResultType == LoginResultType.doubleCheck {
                            // 중복 확인 성공 시
                            output.duplicatedIdCheck.accept(true)
                            output.userNoticeString.accept(.avaliable)
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
                    guard let accessToken = self.authResultModel.tokenDto?.accessToken else { return }
                    let authSaveIdInput = AuthSaveIdInputModel(id: text)
                    
                    AuthNetworkManager.shared.idSavePost(authSaveIdInput, accessToken) { authIdResultModel, loginResultType in
                        if loginResultType == LoginResultType.saveId {
                            guard let userId = self.authResultModel.tokenDto?.userId else { return }
                            guard let refreshToken = self.authResultModel.tokenDto?.refreshToken else { return }
                            TokenManager.saveUserId(userId: String(userId))
                            TokenManager.saveUserAccessToken(accessToken: accessToken)
                            TokenManager.saveUserRefreshToken(refreshToken: refreshToken)
                            output.nextButtonTap.accept(BaseTabBarController())
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Helper Function
    
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

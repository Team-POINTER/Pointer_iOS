//
//  ValidateIdViewModel.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/25.
//

import UIKit
import RxSwift
import RxCocoa

class ValidateIdViewModel: ViewModelType {
    //MARK: - In/Out
    struct Input {
        let idTextFieldEditEvent: Observable<String>
        let idDoubleCheckButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let idTextFieldCountString = BehaviorRelay<String>(value: "0/20")
        let idTextFieldValidString = BehaviorRelay<Bool>(value: false)
        let duplicatedIdCheck = BehaviorRelay<Bool>(value: false)
        let validateIdResult = BehaviorRelay<ValidateIdStyle>(value: .none)
    }
    
    //MARK: - Properties
    private var disposeBag = DisposeBag()
    private var authResultModel: AuthResultModel?
    
    init(authResultModel: AuthResultModel? = nil, existUserId: String? = nil) {
        // 유저 ID가 있었다면 기본값
        self.userEnteredId = BehaviorRelay(value: existUserId)
        self.authResultModel = authResultModel
    }

    //MARK: - Public Properties
    public let didSuccessValidation = BehaviorRelay<Bool>(value: false)
    public let userEnteredId: BehaviorRelay<String?>
    
    //MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        // 텍스트필드 입력 이벤트
        input.idTextFieldEditEvent
            .subscribe { [weak self] text in
                if let text = text.element, text != "",
                   let self = self {
                    /// 글자수 30자 제한
                    let limitedString = self.hintTextFieldLimitedString(text: text)
                    self.userEnteredId.accept(limitedString)
                    
                    /// 제한된 글자수 카운트
                    let textCountString = "\(limitedString.count)/30"
                    output.idTextFieldCountString.accept(textCountString)
                    
                    /// 정규표현식 제한
                    let validString = self.isValidInputString(limitedString)
                    output.idTextFieldValidString.accept(validString)
                    
                    if validString {
                        // 유효성 O
                        output.validateIdResult.accept(.check)
                    } else {
                        // 유효성 X
                        output.validateIdResult.accept(.unformed)
                    }
                    
                    if limitedString == "" {
                        output.validateIdResult.accept(.none)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // 중복확인 버튼 클릭
        input.idDoubleCheckButtonTapEvent
            .withLatestFrom(self.userEnteredId)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                // API 호출
                self.requestValidateId(text ?? "") { model, loginResultType in
                    if loginResultType == LoginResultType.duplicatedId {
                        // ID 중복 시
                        output.duplicatedIdCheck.accept(false)
                        output.validateIdResult.accept(.duplicated)
                    }
                    if loginResultType == LoginResultType.doubleCheck {
                        // 중복 확인 성공 시
                        output.duplicatedIdCheck.accept(true)
                        output.validateIdResult.accept(.avaliable)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 유효성검사 && Validation 완료시
        Observable.combineLatest(output.idTextFieldValidString,
                                 output.duplicatedIdCheck,
                                 resultSelector: { $0 && $1 })
            .subscribe(onNext: { [weak self] didValidated in
                self?.didSuccessValidation.accept(didValidated)
            })
            .disposed(by: disposeBag)
        
        // 
        output.idTextFieldCountString
            .subscribe { _ in
                output.duplicatedIdCheck.accept(false)
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
    //MARK: - Helper Function
    // idTextField 글자 수 제한 함수
    private func hintTextFieldLimitedString(text: String) -> String {
        if text.count > 30 {
            return String(text.prefix(30))
        } else {
            return text
        }
    }
    
    // idTextField 정규표현식 제한 - 영문, 숫자 및 특수문자 . 과 _
    private func isValidInputString(_ input: String) -> Bool {
        let pattern = "^[a-zA-Z0-9._]+$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        let matches = regex.matches(in: input, range: range)
        return !matches.isEmpty
    }
    
    //MARK: - API
    private func requestValidateId(_ stringId: String, completion: @escaping (PointerResultModel, LoginResultType) -> Void) {
        var input: AuthCheckIdInputModel?
        var token: String?
        // authResultModel이 들어온 경우
        if let userData = self.authResultModel?.tokenDto {
            input = AuthCheckIdInputModel(userId: userData.userId, id: stringId)
            token = userData.accessToken
        } else {
            // authResultModel이 들어오지 않은 경우 - 기기에 저장된 데이터를 사용
            input = AuthCheckIdInputModel(userId: TokenManager.getIntUserId(), id: stringId)
            token = TokenManager.getUserAccessToken() ?? ""
        }
        
        // 언래핑
        guard let input = input,
              let token = token else {
            return
        }
        
        // 호출
        AuthNetworkManager.shared.idCheckPost(input, token, completion)
    }
}

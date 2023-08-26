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
        let nextButtonTapEvent: Observable<Void>
        let validateIdViewModel: ValidateIdViewModel
    }
    
    struct Output {
        let duplicatedIdCheck = BehaviorRelay<Bool>(value: false)
        let validateIdResult = BehaviorRelay<ValidateIdStyle>(value: .none)
        let nextButtonValid = BehaviorRelay<Bool>(value: false)
        let errorAlert = PublishRelay<UIViewController>()
        let didProcessDone = PublishRelay<Bool>()
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.nextButtonTapEvent
            .bind(onNext: { [weak self] _ in
                guard let self = self,
                      let id = input.validateIdViewModel.userEnteredId.value else { return }
                // API 호출
                self.requestRegisterAccount(idToSaveAccount: id) { loginResultType in
                    if loginResultType == LoginResultType.saveId {
                        // 성공 - 토큰 저장
                        self.saveUserToken()
                        output.didProcessDone.accept(true)
                    } else {
                        // 에러처리
                        let alert = PointerAlert.getErrorAlert()
                        output.errorAlert.accept(alert)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.validateIdViewModel.didSuccessValidation
            .bind(to: output.nextButtonValid)
            .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Helper Function
    
    //MARK: - API
    private func requestRegisterAccount(idToSaveAccount id: String?, completion: @escaping (LoginResultType?) -> Void) {
        guard let token = authResultModel.tokenDto?.accessToken,
              let id = id else { return }
        AuthNetworkManager.shared.requestRegisterId(idToSaveAccount: id, accessToken: token, completion: completion)
    }
    
    // 유저 토큰 로컬에 저장
    private func saveUserToken() {
        guard let tokenData = authResultModel.tokenDto else { return }
        TokenManager.saveIntUserId(userId: tokenData.userId)
        TokenManager.saveUserAccessToken(accessToken: tokenData.accessToken)
        TokenManager.saveUserRefreshToken(refreshToken: tokenData.refreshToken)
    }
}

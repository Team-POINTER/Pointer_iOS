//
//  EditUserIDViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/11.
//

import UIKit
import RxSwift
import RxCocoa

class EditUserIDViewModel: ViewModelType {
    //MARK: - Input/Output
    struct Input {
        let saveButtonTapEvent: Observable<Void>
        let validateIdViewModel: ValidateIdViewModel
    }
    
    struct Output {
        let isSaveButtonActive = BehaviorRelay<Bool>(value: false)
        let isSuccessSaveUserId = BehaviorRelay<(Bool, String?)>(value: (false, nil))
        let errorAlert = PublishRelay<UIViewController>()
    }
    
    //MARK: - Properties
    var disposeBag = DisposeBag()
    lazy var authNetwork = AuthNetworkManager()
    lazy var profileNetwork = ProfileNetworkManager()
    let user: ProfileModel?
    var userIdToEdit: String?
    
    //MARK: - Init
    init(user: ProfileModel?) {
        self.user = user
        self.userIdToEdit = user?.results?.id
    }
    
    //MARK: - Functions
    func transform(input: Input) -> Output {
        let output = Output()
        
        // 저장 버튼 활성화
        input.validateIdViewModel.didSuccessValidation
            .bind(to: output.isSaveButtonActive)
            .disposed(by: disposeBag)
        
        // 저장 버튼 탭
        input.saveButtonTapEvent
            .withLatestFrom(input.validateIdViewModel.userEnteredId)
            .subscribe(onNext: { [weak self] id in
                guard let self = self else { return }
                // API 호출
                self.requestSaveAccount(idToSaveAccount: id) { loginResultType in
                    if loginResultType == LoginResultType.saveId {
                        output.isSuccessSaveUserId.accept((true, id))
                    } else {
                        // 에러처리
                        let alert = PointerAlert.getErrorAlert()
                        output.errorAlert.accept(alert)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    //MARK: - API
    private func requestSaveAccount(idToSaveAccount id: String?, completion: @escaping (LoginResultType?) -> Void) {
        guard let token = TokenManager.getUserAccessToken(),
              let id = id else { return }
        AuthNetworkManager.shared.requestRegisterId(idToSaveAccount: id, accessToken: token, completion: completion)
    }
}

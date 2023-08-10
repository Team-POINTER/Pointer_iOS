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
    let idMaxCount: Int = 30
    //MARK: - 유효성 검사 결과
    enum CheckValidateResult: CaseIterable {
        case available
        case outOfPolicy
        case alreadyInUse
        
        var resultString: String {
            switch self {
            case .available: return "사용가능한 아이디입니다."
            case .outOfPolicy: return "형식에 어긋난 아이디입니다."
            case .alreadyInUse: return "중복되는 아이디입니다."
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .available: return .inactiveGray
            default: return .pointerRed
            }
        }
    }
    
    //MARK: - Input/Output
    struct Input {
        let idTextFieldEvent: Observable<String>
        let idValidationButtonTapped: Observable<Void>
        let saveButtonTapped: Observable<Void>
    }
    
    struct Output {
        let checkLimitedIdString = PublishRelay<String>()
        let checkValidateResult = PublishRelay<CheckValidateResult>()
        let checkIdStringCountString: BehaviorRelay<String>
        let isSaveButtonActive = BehaviorRelay<Bool>(value: false)
        let isSuccessSaveUserId = BehaviorRelay<(Bool, String?)>(value: (false, nil))
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
        let output = Output(checkIdStringCountString: BehaviorRelay(value: getIdStringCount(user?.results?.id ?? "오류")))
        
        /// 중복확인 버튼 클릭 이벤트
        /// 1. 가장 최신의 ID를 가지고
        /// 2. Validation 요청
        /// 3. 결과에 따라 저장 버튼 활성화 여부 푸시
        input.idValidationButtonTapped
            .withLatestFrom(output.checkLimitedIdString)
            .subscribe { [weak self] string in
                guard let self = self else { return }
                self.requestIdValidation(string.element) { result in
                    if result == .duplicatedId {
                        output.checkValidateResult.accept(.alreadyInUse)
                        output.isSaveButtonActive.accept(false)
                    } else if result == .doubleCheck {
                        output.checkValidateResult.accept(.available)
                        output.isSaveButtonActive.accept(true)
                    } else if result == .haveToCheckId {
                        
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // ID 텍스트필드 입력 이벤트
        input.idTextFieldEvent
            .subscribe { [weak self] string in
                if let text = string.element,
                   let self = self {
                    // 1. 아이디 30자 넘지 않게 제한
                    let limitedString = self.checkLimitString(text)
                    output.checkLimitedIdString.accept(limitedString)
                    // 2. String 수 계산
                    let textCountString = self.getIdStringCount(limitedString)
                    self.userIdToEdit = limitedString
                    // 푸시
                    output.isSaveButtonActive.accept(false)
                    output.checkIdStringCountString.accept(textCountString)
                }
            }.disposed(by: disposeBag)
        
        // 저장 버튼
        input.saveButtonTapped
            .withLatestFrom(output.checkLimitedIdString)
            .subscribe { [weak self] text in
                guard let self = self,
                      let text = text.element else { return }
                self.authNetwork.idSavePost(AuthSaveIdInputModel(id: text),
                                            TokenManager.getUserAccessToken() ?? "") { result, type in
                    if type == .saveId {
                        print("👉변경 성공")
                        output.isSuccessSaveUserId.accept((true, text))
                    } else {
                        print("👉변경 실패")
                        output.isSuccessSaveUserId.accept((false, nil))
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
    // 글자 수 제한
    private func checkLimitString(_ text: String) -> String {
        guard text.count <= 30 else {
            let limitedText = String(text.prefix(30))
            return limitedText
        }
        return text
    }
    
    // 글자 수 세기
    private func getIdStringCount(_ text: String) -> String {
        return "\(text.count)/\(idMaxCount)"
    }
    
    //MARK: - API
    func requestIdValidation(_ idToValidate: String?, completion: @escaping (LoginResultType) -> Void) {
        // 0. Validation
        guard let userId = idToValidate, userId != user?.results?.id, userId.count <= 30 else {
            print("Validation 실패")
            return
        }
        
        // 1. 중복확인
        let input = AuthCheckIdInputModel(userId: TokenManager.getIntUserId(), id: userId)
        authNetwork.idCheckPost(input, TokenManager.getUserAccessToken() ?? "") { model, resultType in
            completion(resultType)
        }
    }
}

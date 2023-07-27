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
    var disposeBag = DisposeBag()
    struct Input {
        let idTextFieldEvent = PublishRelay<String>()
    }
    
    struct Output {
        let checkValidateResult = PublishRelay<CheckValidateResult>()
        let checkIdStringCountString: BehaviorRelay<String>
    }
    
    //MARK: - Properties
    let user: ProfileModel?
    
    //MARK: - Init
    init(user: ProfileModel?) {
        self.user = user
    }
    
    //MARK: - Functions
    func transform(input: Input) -> Output {
        let output = Output(checkIdStringCountString: BehaviorRelay(value: getIdStringCount(text: user?.results?.id ?? "오류")))
        
        input.idTextFieldEvent
            .subscribe { [weak self] string in
                if let text = string.element,
                   let self = self {
                    let textCountString = self.getIdStringCount(text: text)
                    output.checkIdStringCountString.accept(textCountString)
                }
            }.disposed(by: disposeBag)

        return output
    }
    
    private func getIdStringCount(text: String) -> String {
        return "\(text.count)/\(idMaxCount)"
    }
}

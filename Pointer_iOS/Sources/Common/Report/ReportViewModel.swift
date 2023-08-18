//
//  ReportViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/23.
//

import UIKit
import RxSwift
import RxCocoa

enum ReportType: String, CaseIterable {
    case question = "QUESTION"
    case hint = "HINT"
}

enum ReasonCode: String, CaseIterable {
    case spam = "SPAM"
    case insult = "INSULT"
    case sexualAversion = "SEXUAL_AVERSION"
    case violence = "VIOLENCE"
    case custom = "CUSTOM"
    
    var reason: String {
        switch self {
        case .spam:
            return "스팸"
        case .insult:
            return "모욕적인 문장"
        case .sexualAversion:
            return "성적 혐오 발언"
        case .violence:
            return "폭력 또는 따돌림"
        case .custom:
            return "기타 사유"
        }
    }
}

class ReportViewModel: ViewModelType {
    
//MARK: - Properties
    let disposeBag = DisposeBag()
    let dismissReportView = BehaviorRelay<Bool>(value: false)
    
    var reason = ""
    
    let roomId: Int
    let questionId: Int
    let type: String
    let targetUserId: Int
    let presentingReason: String
    let reasonCode: String
    
//MARK: - Life Cycles
    init(roomId: Int, questionId:Int, type: ReportType, targetUserId: Int, presentingReason: String, reasonCode: String) {
        self.roomId = roomId
        self.questionId = questionId
        self.type = type.rawValue
        self.targetUserId = targetUserId
        self.presentingReason = presentingReason
        self.reasonCode = reasonCode
    }
    
//MARK: - In/Out
    struct Input {
        let reportText: Observable<String>
        let submitButtonTapedEvent: Observable<Void>
    }
    
    struct Output {
        let limitText = BehaviorRelay<String>(value: "")
        let reportTextCount = BehaviorRelay<String>(value: "")
        let submitButtonValid = BehaviorRelay<Bool>(value: false)
    }
    
//MARK: - Rx Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.reportText
            .subscribe { [weak self] text in
                guard let self = self,
                      let text = text.element else { return }
                
                // 글자 수 500자 제한
                let limitText = self.textFieldLimitedString(text: text)
                output.limitText.accept(limitText)
                self.reason = limitText
                
                // textCount 바인딩
                if text == "포인터 팀이 조치를 취해드릴 수 있게 문제 상황을 최대한 구체적으로 설명해주세요." {
                    let limitTextCount = "0/500"
                    output.reportTextCount.accept(limitTextCount)
                    output.submitButtonValid.accept(false)
                } else {
                    let limitTextCount = "\(limitText.count)/500"
                    output.reportTextCount.accept(limitTextCount)
                    // count가 0 이상일 때만 true
                    if limitText.count > 0 {
                        output.submitButtonValid.accept(true)
                    } else {
                        output.submitButtonValid.accept(false)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.submitButtonTapedEvent
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                let model = ReportRequestModel(roomId: self.roomId,
                                               dataId: self.questionId,
                                               type: self.type,
                                               targetUserId: self.targetUserId,
                                               reason: self.reason,
                                               reasonCode: self.reasonCode)
                
                self.reportRequest(model: model)
            }
            .disposed(by: disposeBag)
        
        return output
    
    }

    
//MARK: - Helper
    private func textFieldLimitedString(text: String) -> String {
        if text.count > 20 {
            return String(text.prefix(500))
        } else {
            return text
        }
    }
    
//MARK: - Network
    func reportRequest(model: ReportRequestModel) {
        ReportNetworkManager.shared.reportRequest(parameter: model) { [weak self] (error, model) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let model = model {
                // 일단 신고 생성되면 dismiss -> 추후 신고 기능에 따라 변경
                print("🔥DEBUG: 신고 완료 - \(model)")
                self?.dismissReportView.accept(true)
            }
        }
    }
}

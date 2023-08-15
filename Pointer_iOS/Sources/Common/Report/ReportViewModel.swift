//
//  ReportViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/23.
//

import UIKit
import RxSwift
import RxCocoa

class ReportViewModel: ViewModelType {
    
//MARK: - Properties
    let disposeBag = DisposeBag()
    
//    let roomId: Int
//    let questionId: Int
//    let type: String // enum이 좋을듯
//    let reasonCode: String
    let userId = TokenManager.getIntUserId()
    var reason = ""
    
    let roomId = 0
    let questionId = 0
    let type = "" // enum이 좋을듯
    let reasonCode = ""
    
    
//MARK: - Life Cycles
    init() { // roomId: Int, questionId:Int, type: String, reasonCode: String
//        self.roomId = roomId
//        self.questionId = questionId
//        self.type = type
//        self.reasonCode = reasonCode
    }
    
//MARK: - In/Out
    struct Input {
        let reportText: Observable<String>
        let submitButtonTapedEvent: Observable<Void>
    }
    
    struct Output {
        let limitText = BehaviorRelay<String>(value: "")
        let reportTextCount = BehaviorRelay<String>(value: "")
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
                } else {
                    let limitTextCount = "\(limitText.count)/500"
                    output.reportTextCount.accept(limitTextCount)
                }
            }
            .disposed(by: disposeBag)
        
        return output
        
        input.submitButtonTapedEvent
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                let model = ReportRequestModel(roomId: self.roomId,
                                               dataId: self.questionId,
                                               type: self.type,
                                               targetUserId: self.userId,
                                               reportingUserId: 0,
                                               reason: self.reason,
                                               reasonCode: self.reasonCode)
                
                self.reportRequest(model: model)
            }
            .disposed(by: disposeBag)
            
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
        ReportNetworkManager.shared.reportRequest(parameter: model) { (error, model) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let model = model {
                print("DEBUG: 신고 데이터 분기 처리")
            }
        }
    }
}

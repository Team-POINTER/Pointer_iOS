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
    
//MARK: - In/Out
    struct Input {
        let reportText: Observable<String>
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
    }

    
    //MARK: - Helper
    func textFieldLimitedString(text: String) -> String {
        if text.count > 20 {
            return String(text.prefix(500))
        } else {
            return text
        }
    }
    
}

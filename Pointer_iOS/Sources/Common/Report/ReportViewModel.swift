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
    
    struct Input {
        let reportText: Observable<String>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.reportText
            .subscribe { text in
                print(text)
            }
            .disposed(by: disposeBag)
        
        return output
    }

    
    //MARK: - Helper
}

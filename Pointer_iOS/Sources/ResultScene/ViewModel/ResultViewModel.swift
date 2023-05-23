//
//  ResultViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/19.
//

import UIKit
import RxSwift
import RxCocoa

class ResultViewModel: ViewModelType{
    
    enum timeLabelStyle: CaseIterable {
        case isHidden
        case isNotHidden
        
        var isHidden: Bool {
            switch self {
            case .isHidden: return true
            case .isNotHidden: return false
            }
        }
        
        func getTimeString(_ time: Int) -> String {
            switch self {
            case .isHidden:
                return " "
            case .isNotHidden:
                let hours = time / 3600
                let minutes = (time % 3600) / 60
                let seconds = time % 60
                let changingTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                return changingTime
            }
        }
    }
    
//MARK: - Properties
    // resultView에 맞는 모델 [X] -> API 연결 시
    
    var timeString = "2023-05-23 14:25:15"
    
    let remainingTime = BehaviorSubject<Int>(value: 0)
    private var timer: Timer?
    
    
    let disposeBag = DisposeBag()
    
//MARK: - In/Out
    struct Input {
        //viewdidload가 되었다면 모델데이터를 불러오나?
    }
    
    struct Output {
        let timeLabelIsHidden = PublishSubject<timeLabelStyle>()
    }

//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        remainingTime
            .subscribe { time in
//                print("ResultViewModel function called \(time)")
                guard let time = time.element else { return }
                if time <= 0 {
                    output.timeLabelIsHidden.onNext(.isHidden)
                } else {
                    output.timeLabelIsHidden.onNext(.isNotHidden)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
    
//MARK: - Functions
    func startTimer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let endDate = formatter.date(from: timeString) else { return }
        self.remainingTime.onNext(Int(endDate.timeIntervalSinceNow))
        guard let remainingTimeValue = try? self.remainingTime.value() else {
            return
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let remainingTimeValue = (try? self.remainingTime.value()) ?? 0
            self.remainingTime.onNext(remainingTimeValue - 1)
            if remainingTimeValue == 0 {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
    
}

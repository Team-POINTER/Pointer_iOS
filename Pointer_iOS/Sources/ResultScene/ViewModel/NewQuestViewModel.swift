//
//  NewQuestViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/05/12.
//

// enum으로 관리할 부분과 output 바인딩을 어떻게 가져갈지?

import UIKit
import RxSwift
import RxCocoa

class NewQuestViewModel: ViewModelType{
    
    var timeString = "2023-05-13 12:15:57"
    
//MARK: - Properties
    let remainingTime = BehaviorSubject<Int>(value: 0)
    let timerExpired = PublishSubject<Bool>()
    private var timer: Timer?
    
    let disposeBag = DisposeBag()
    
//MARK: - In/Out
    struct Input {
        
    }
    
    struct Output {
        
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        
        return Output()
    }
    
    
//MARK: - Functions
    func startTimer(withEndTime endTime: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let endDate = formatter.date(from: endTime) else { return }
        self.remainingTime.onNext(Int(endDate.timeIntervalSinceNow))
        guard let remainingTimeValue = try? self.remainingTime.value(), remainingTimeValue > 0 else {
            self.timerExpired.onNext(false)
            return
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let remainingTimeValue = (try? self.remainingTime.value()) ?? 0
    
            self.remainingTime.onNext(remainingTimeValue - 1)
            if remainingTimeValue == 0 {
                self.timerExpired.onNext(true)
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
}

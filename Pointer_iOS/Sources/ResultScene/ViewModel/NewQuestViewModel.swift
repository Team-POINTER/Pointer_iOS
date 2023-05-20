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
    
    enum nextQuestButtonStyle: CaseIterable {
        case isEnable
        case disable
        
        var isEnable: Bool {
            switch self {
            case .isEnable: return true
            case .disable: return false
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .isEnable:
                return UIColor.pointerRed
            case .disable:
                return UIColor.pointerRed.withAlphaComponent(0.5)
            }
        }
        
        func getAttributedString(_ time: Int) -> NSMutableAttributedString {
            switch self {
            case .isEnable:
                let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
                return attributedQuestionString
            case .disable:
                let hours = time / 3600
                let minutes = (time % 3600) / 60
                let seconds = time % 60
                let changingTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                
                let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기 ", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
                attributedQuestionString.append(NSMutableAttributedString(string: "\(changingTime)", attributes: [.font: UIFont.notoSans(font: .notoSansKrMedium, size: 17), .foregroundColor: UIColor.white]))
                return attributedQuestionString
            }
        }
    }
    
    var timeString = "2023-05-20 23:20:20"
    
//MARK: - Properties
    let remainingTime = BehaviorSubject<Int>(value: 0)
    let timerExpired = PublishSubject<Bool>()
    private var timer: Timer?
    
    let disposeBag = DisposeBag()
    
//MARK: - In/Out
    struct Input {
        
    }
    
    struct Output {
        let buttonIsEnable = PublishSubject<nextQuestButtonStyle>()
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        
        let output = Output()
        
        
        remainingTime
            .subscribe { time in
                print("function called \(time)")
                guard let time = time.element else { return }
                if time <= 0 {
                    output.buttonIsEnable.onNext(.isEnable)
                } else {
                    output.buttonIsEnable.onNext(.disable)
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

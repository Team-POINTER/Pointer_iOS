//
//  ResultViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/19.
//

import UIKit
import RxSwift
import RxCocoa

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

class ResultViewModel: ViewModelType{
    
//MARK: - Properties
    // resultView에 맞는 모델 [X] -> API 연결 시
    
    var limitedAt = ""
    var roomId = 0
    var userName = ""
    
    let remainingTime = BehaviorSubject<Int>(value: 0)
    let votedResultObservable = PublishRelay<VotedResultData>()
    private var timer: Timer?
    
    
    let disposeBag = DisposeBag()
    
    
//MARK: - init
    init(_ roomId: Int, _ questionId: Int, _ limitedAt: String) {
        self.roomId = roomId
        resultRequest(questionId)
        self.limitedAt = limitedAt
    }
    
//MARK: - In/Out
    struct Input {
        let myResultButtonTap: Observable<Void>
        let newQuestionButtonTap: Observable<Void>
    }
    
    struct Output {
        let timeLabelIsHidden = PublishSubject<timeLabelStyle>()
        let myResultButtonTap = PublishRelay<UIViewController>()
        let newQuestionButtonTap = PublishRelay<UIViewController>()
    }

//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.myResultButtonTap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                output.myResultButtonTap.accept(MyResultViewController(viewModel: MyResultViewModel(self.roomId, self.userName)))
            }
            .disposed(by: disposeBag)
        
        input.newQuestionButtonTap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                output.newQuestionButtonTap.accept(NewQuestViewController())
            }
            .disposed(by: disposeBag)
        
        remainingTime
            .subscribe { time in
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
        guard let endDate = formatter.date(from: limitedAt) else { return }
        let remainingTimeInterval = Int(endDate.timeIntervalSinceNow)
        self.remainingTime.onNext(remainingTimeInterval)

        if remainingTimeInterval > 0 {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                let remainingTimeValue = (try? self.remainingTime.value()) ?? 0
                self.remainingTime.onNext(remainingTimeValue - 1)
                if remainingTimeValue == 0 {
                    self.stopTimer()
                }
            }
        }
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
//MARK: - Network
    func resultRequest(_ questionId: Int) {
        ResultNetworkManager.shared.votedResultRequest(questionId)
            .subscribe(onNext: { [weak self] data in
                self?.votedResultObservable.accept(data)
                self?.userName = data.targetUser.userName
            }, onError: { error in
                print("DEBUG: ResultViewModel - resultRequest Error: \(error.localizedDescription)")
            } )
            .disposed(by: disposeBag)
    }
    
}

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
    
    let limitedAt: String
    let roomId: Int
    let questionId: Int
    
    var userName = ""
    var roomName = ""
    var question = ""
    
    // 룸 인원이 전부 투표 했는지 여부
    var notVotedMeberCnt = 0
    
    let remainingTime = BehaviorSubject<Int>(value: 0)
    let votedResultObservable = PublishRelay<VotedResultData>()
    private var timer: Timer?
    
    
    let disposeBag = DisposeBag()
    
    
//MARK: - init
    init(_ roomId: Int, _ questionId: Int, _ limitedAt: String) {
        self.roomId = roomId
        self.limitedAt = limitedAt
        self.questionId = questionId
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
        resultRequest(self.questionId)
        
        input.myResultButtonTap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                output.myResultButtonTap.accept(MyResultViewController(viewModel: MyResultViewModel(self.roomId, self.userName, self.roomName)))
            }
            .disposed(by: disposeBag)
        
        input.newQuestionButtonTap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                output.newQuestionButtonTap.accept(NewQuestViewController(viewModel: NewQuestViewModel(limitedAt: self.limitedAt, roomName: self.roomName, roomId: self.roomId)))
            }
            .disposed(by: disposeBag)
        
        remainingTime
            .subscribe { [weak self] time in
                guard let time = time.element,
                      let self = self else { return }
                
                // 룸의 인원이 전부 투표하지 않았을 경우에만
                if self.notVotedMeberCnt > 0 {
                    if time <= 0 {
                        output.timeLabelIsHidden.onNext(.isHidden)
                    } else {
                        output.timeLabelIsHidden.onNext(.isNotHidden)
                    }
                // 전부 투표한 경우
                } else {
                    output.timeLabelIsHidden.onNext(.isHidden)
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
                self?.notVotedMeberCnt = data.notNotedMemberCnt
                self?.userName = data.targetUser.userName
                self?.roomName = data.roomName
                self?.question = data.question
            }, onError: { error in
                print("DEBUG: ResultViewModel - resultRequest Error: \(error.localizedDescription)")
            } )
            .disposed(by: disposeBag)
    }
    
}

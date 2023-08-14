//
//  NewQuestViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/05/12.
//

import UIKit
import RxSwift
import RxCocoa

enum NewQuestResponse: String, CaseIterable {
    case success = "A200"
    case roomError = "J004"
    case accountError = "C001"
    case questionError = "K000"
}

enum NextQuestButtonStyle: CaseIterable {
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
            let changingTime = String("00:00:00")
            
            let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기 ", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
            attributedQuestionString.append(NSMutableAttributedString(string: "\(changingTime)", attributes: [.font: UIFont.notoSans(font: .notoSansKrMedium, size: 17), .foregroundColor: UIColor.white]))
            return attributedQuestionString
        case .disable:
            let hours = time / 3600
            let minutes = (time % 3600) / 60
            let seconds = time % 60
            let changingTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기 ", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
            attributedQuestionString.append(NSMutableAttributedString(string: "\(changingTime)", attributes: [.font: UIFont.notoSans(font: .notoSansKrMedium, size: 17), .foregroundColor: UIColor.white.withAlphaComponent(0.5)]))
            return attributedQuestionString
        }
    }
}

class NewQuestViewModel: ViewModelType{
    
//MARK: - Properties
    
    var limitedAt = ""
    var roomName = ""
    var roomId = 0
    var userId = TokenManager.getIntUserId()
    var questionInputString = "" // 텍스트필드 입력 값
    
    // 룸 인원이 전부 투표 했는지 여부
    var notVotedMemberCnt = 0
    
    let remainingTime = BehaviorSubject<Int>(value: 0)
    private var timer: Timer?
    
    let disposeBag = DisposeBag()
    
//MARK: - Init
    init(limitedAt: String, roomName: String, roomId: Int, notVotedMemberCnt: Int) {
        self.limitedAt = limitedAt
        self.roomName = roomName
        self.roomId = roomId
        self.notVotedMemberCnt = notVotedMemberCnt
        self.startTimer()
    }
    
//MARK: - In/Out
    struct Input {
        let newQuestTextViewEditEvent: Observable<String>
        let newQuestButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let timeLimited = BehaviorRelay<Bool>(value: false)
        let newQuestTextViewText = BehaviorRelay<String>(value: "")
        let buttonIsEnable = BehaviorRelay<NextQuestButtonStyle>(value: .disable)
        let backAlert = BehaviorRelay<NewQuestResponse?>(value: nil)
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        
        let output = Output()
        // 질문 입력 시
        input.newQuestTextViewEditEvent
            .subscribe { [weak self] text in
                guard let self = self else { return }
                let limitedCountText = self.textViewLimitedString(text: text)
        
                self.questionInputString = limitedCountText
                output.newQuestTextViewText.accept(limitedCountText)
            }
            .disposed(by: disposeBag)
        
        // 질문 등록하기 버튼 Tap
        input.newQuestButtonTapEvent
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                print("질문 등록 버튼 Tap")
                let newQuestionRequestModel = NewQuestionRequestModel(roomId: self.roomId,
                                                                      content: self.questionInputString)
                ResultNetworkManager.shared.newQuestionRequest(newQuestionRequestModel) { (error, model) in
                    if let error = error {
                        print("질문 등록 에러: \(error.localizedDescription)")
                    }
                    
                    if let model = model {
                        // 질문 생성 실패
                        if NewQuestResponse.questionError.rawValue == model.code {
                            output.backAlert.accept(NewQuestResponse.questionError)
                        // 질문 생성 성공
                        } else if NewQuestResponse.success.rawValue == model.code {
                            output.backAlert.accept(NewQuestResponse.success)
                        // 회원 정보 없음
                        } else if NewQuestResponse.accountError.rawValue == model.code {
                            output.backAlert.accept(NewQuestResponse.accountError)
                        // 룸 조회 실패
                        } else {
                            output.backAlert.accept(NewQuestResponse.roomError)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        remainingTime
            .subscribe { [weak self] time in
                guard let time = time.element,
                      let self = self else { return }
                
                // 남아있는 시간이 0보다 작거나 룸 인원이 전부 투표한 경우
                if time <= 0 || self.notVotedMemberCnt == 0 {
                    output.timeLimited.accept(true)
                    output.buttonIsEnable.accept(.isEnable)
                } else {
                    output.timeLimited.accept(false)
                    output.buttonIsEnable.accept(.disable)
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
    
    // 45자 제한
    func textViewLimitedString(text: String) -> String {
        if text.count > 45 {
            return String(text.prefix(45))
        } else {
            return text
        }
    }
}

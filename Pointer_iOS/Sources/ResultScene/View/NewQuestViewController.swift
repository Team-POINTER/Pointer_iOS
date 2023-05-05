//
//  NewQuestViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/04/02.
//

import UIKit
import SnapKit

// 1. timeString값으로 남은 시간을 받아오고 카운트 다운 버튼 활성화 [O]
// 2. 초기에 서버에게 질문 등록하기 버튼 활성화의 유무를 받아서 바로 적용 [X]

class NewQuestViewController: BaseViewController {

    var timeString = "2023-05-05 22:39:05"
    var remainedTime = ""
//    var newQuestionButtonEnabled = true
    
//MARK: - UI Components
    
    private let questAlertLabel : UILabel = {
        $0.text = "해당 룸에 하고 싶은 질문을 작성해주세요!\n24시간마다 선착순 1명이 질문할 수 있습니다."
        $0.font = UIFont.notoSansRegular(size: 12)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var newQuestLabel: UILabel = {
        $0.text = "질문을 입력하세요."
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 20)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    lazy var newQuestButton: UIButton = {
        let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
        $0.setAttributedTitle(attributedQuestionString, for: .normal)
        $0.layer.cornerRadius = 25
        $0.backgroundColor = UIColor.gray
        $0.titleLabel?.textColor = UIColor.white
//        self.newQuestButton.isEnabled = newQuestionButtonEnabled
        return $0
    }(UIButton())
    
    let inviteButton: UIButton = {
        $0.setTitle("링크로 초대", for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 16)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 25
        $0.backgroundColor = UIColor.clear
        $0.titleLabel?.textColor = UIColor.white
        return $0
    }(UIButton())
        
//MARK: - set UI
    func setUI(){
        view.addSubview(questAlertLabel)
        view.addSubview(newQuestLabel)
        view.addSubview(newQuestButton)
        view.addSubview(inviteButton)
    }
    
    func setConstraints() {
        questAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(75)
            make.centerX.equalToSuperview()
        }
        newQuestLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().inset(45.5)
            make.trailing.equalToSuperview().inset(45.5)
        }
        newQuestButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(-30)
            make.leading.equalToSuperview().inset(18)
            make.height.equalTo(50)
            make.width.equalTo(Device.width / 2 + 10)
        }
        inviteButton.snp.makeConstraints { make in
            make.centerY.equalTo(newQuestButton.snp.centerY)
            make.trailing.equalToSuperview().inset(18)
            make.height.equalTo(50)
            make.width.equalTo(Device.width / 3)
        }
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setConstraints()
        buttonTimer()
        
    }
    
    
    func buttonTimer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let endDate = formatter.date(from: self.timeString) else { return }
        print(endDate)
        var remainingTime = Int(endDate.timeIntervalSinceNow)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            remainingTime -= 1
            let hours = remainingTime / 3600
            let minutes = (remainingTime % 3600) / 60
            let seconds = remainingTime % 60
            self.remainedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            // 버튼 타이틀 갱신
            let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기 ", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
            attributedQuestionString.append(NSMutableAttributedString(string: "\(self.remainedTime)", attributes: [.font: UIFont.notoSans(font: .notoSansKrMedium, size: 17), .foregroundColor: UIColor.white]))
            self.newQuestButton.setAttributedTitle(attributedQuestionString, for: .normal)
            
            // 남은 시간이 0이 되면 타이머 종료
            if self.remainedTime == "00:00:00" {
                timer.invalidate()
                self.newQuestButton.isEnabled = true
                self.newQuestButton.backgroundColor = .pointerRed
                let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
                self.newQuestButton.setAttributedTitle(attributedQuestionString, for: .normal)
            }
        }
    }
    

    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
        self.title = "룸 이름"
    }
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}

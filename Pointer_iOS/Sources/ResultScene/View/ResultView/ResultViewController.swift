//
//  ResultViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FloatingPanel
import SendbirdUIKit

// 1. 현재 타이머 시간을 viewModel에 있는 timeString으로 시작

class ResultViewController: BaseViewController {
    
    var viewModel = ResultViewModel()
    let disposeBag = DisposeBag()
    
//MARK: - Rx
    func bindViewModel() {
        
        let input = ResultViewModel.Input()
        let output = viewModel.transform(input: input)
        
        myResultButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(MyResultViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        newQuestionButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let vc = NewQuestViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(output.timeLabelIsHidden, viewModel.remainingTime)
            .bind { [weak self] style, time in
                guard let self = self else { return }
                print("DEBUG: label Status - \(style)")
                print("DEBUG: time - \(time)")
                self.newQuestionTimerLabel.text = style.getTimeString(time)
                self.newQuestionTimerLabel.isHidden = false
            }
            .disposed(by: disposeBag)
        
        
        
        viewModel.startTimer()
        
    }
    
//MARK: - UIComponents
    var scrollView: UIScrollView = {
        $0.bounces = false
        return $0
    }(UIScrollView())
    
    var hintText: UILabel = {
        $0.text = "한 20년 뒤 미래에 가장 돈을 잘 벌 것 같은 사람은 누구인가? 최대 공백포함 45"
        $0.font = UIFont.notoSansRegular(size: 18)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var selectedPeopleLabel: UILabel = {
        $0.text = " 1. Jane Cooper\n 2. Ronald Richaaaaaard\n 3. Bessie Cooper\n 4. Jane Cooper\n 5. Ronald Richaaaaaard\n 6. Bessie Cooper\n"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 18)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var selectedPointLabel: UILabel = {
        $0.text = "10 / 20\n  4 / 20\n  3 / 20\n  1 / 20\n  1 / 20\n  1 / 20\n"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 18)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var myNameLabel: UILabel = {
        $0.text = "포인터 님"
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.white
        return $0
    }(UILabel())
    
    var mySelectedPointLabel: UILabel = {
        $0.text = "3 / 20"
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.pointerRed
        return $0
    }(UILabel())
    
    let myResultButton : UIButton = {
        $0.setTitle("나의 결과보기", for: .normal)
        $0.setTitleColor(UIColor.pointerRed, for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 16)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 22
        return $0
    }(UIButton())
    
    var newQuestionTimerLabel: UILabel = {
        $0.text = "22:23:34"
        $0.font = UIFont.notoSansRegular(size: 14)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    let newQuestionButton : UIButton = {
        $0.setTitle("새 질문 등록하기", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 16)
        $0.backgroundColor = UIColor.pointerRed
        $0.layer.cornerRadius = 22
        return $0
    }(UIButton())
    
    var kokButton: UIButton = {
        var attributedString = NSMutableAttributedString(string: "지목하지 않은 사람에게 콕!  4명")
        attributedString.addAttribute(.font, value: UIFont.notoSansBold(size: 16), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: 15))
        attributedString.addAttribute(.foregroundColor, value: UIColor.rgb(red: 121, green: 125, blue: 148), range: NSRange(location: 16, length: 3))
        $0.setAttributedTitle(attributedString, for: .normal)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 22
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        return $0
    }(UIButton())

    
    var resultChatView = ResultChatView()
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setUIConstraints()
        bindViewModel()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chatTaped))
        resultChatView.view.addGestureRecognizer(tapGesture)
        resultChatView.view.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
        
        self.title = "룸 이름"
        // - navigation bar title 색상 변경
    }
    
//MARK: - Set UI
    func setUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(hintText)
        scrollView.addSubview(selectedPeopleLabel)
        scrollView.addSubview(selectedPointLabel)
        scrollView.addSubview(myNameLabel)
        scrollView.addSubview(mySelectedPointLabel)
        scrollView.addSubview(myResultButton)
        scrollView.addSubview(newQuestionTimerLabel)
        scrollView.addSubview(newQuestionButton)
        scrollView.addSubview(kokButton)
        view.addSubview(resultChatView)
    }
    
    func setUIConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hintText.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(33)
            make.leading.trailing.equalToSuperview().inset(45)
        }
        selectedPeopleLabel.snp.makeConstraints { make in
            make.top.equalTo(hintText.snp.bottom).inset(-30)
            make.leading.equalToSuperview().inset(53)
        }
        selectedPointLabel.snp.makeConstraints { make in
            make.top.equalTo(hintText.snp.bottom).inset(-30)
            make.trailing.equalToSuperview().inset(55)
        }
        myNameLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedPeopleLabel.snp.bottom).inset(15)
            make.leading.equalToSuperview().inset(60)
        }
        mySelectedPointLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedPointLabel.snp.bottom).inset(15)
            make.trailing.equalToSuperview().inset(55)
        }
        myResultButton.snp.makeConstraints { make in
            make.top.equalTo(myNameLabel.snp.bottom).inset(-60)
            make.leading.equalToSuperview().inset(34.5)
            make.width.equalTo(145)
            make.height.equalTo(44)
        }
        newQuestionButton.snp.makeConstraints { make in
            make.centerY.equalTo(myResultButton.snp.centerY)
            make.trailing.equalToSuperview().inset(34.5)
            make.width.equalTo(145)
            make.height.equalTo(44)
        }
        newQuestionTimerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(newQuestionButton.snp.top).inset(-5)
            make.centerX.equalTo(newQuestionButton.snp.centerX)
        }
        kokButton.snp.makeConstraints { make in
            make.top.equalTo(myResultButton.snp.bottom).inset(-20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(34.5)
            make.height.equalTo(50)
        }

        resultChatView.snp.makeConstraints { make in
            make.top.equalTo(kokButton.snp.bottom).inset(-30)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalTo(UIScreen.main.bounds.width - 32)
            make.height.equalTo(135)
        }
    }
    
        
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func chatTaped() {
//        let resultChatViewController = FloatingChatViewController(contentViewController: RoomFloatingChatViewController())
//        present(NextTestViewController(), animated: true)
        let testViewController = NextTestViewController()
        let resultChatViewController = ChattingRoomViewController(channelURL: "sendbird_group_channel_121580584_0a41445ba95f50f74241bb813d7d0cc9fcf68576")
//        resultChatViewController.modalPresentationStyle = .pageSheet
//        present(resultChatViewController, animated: true)
        self.navigationController?.pushViewController(resultChatViewController, animated: true)
    }
    
    
}

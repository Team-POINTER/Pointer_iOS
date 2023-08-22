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

protocol ResultViewControllerDelegate: AnyObject {
    func didChangedRoomStateFromResultVC()
}

class ResultViewController: BaseViewController {
//MARK: - properties
    var viewModel: ResultViewModel
    let disposeBag = DisposeBag()
    weak var delegate: ResultViewControllerDelegate?
    
//MARK: - Init
    init(viewModel: ResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.newQuestionTimerLabel.text = viewModel.limitedAt
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Rx
    func bindViewModel() {
        
        let input = ResultViewModel.Input(myResultButtonTap: myResultButton.rx.tap.asObservable(),
                                          newQuestionButtonTap: newQuestionButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.myResultButtonTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewController in
                guard let self = self else { return }
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        output.newQuestionButtonTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewController in
                guard let self = self else { return }
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(output.timeLabelIsHidden, viewModel.remainingTime)
            .bind { [weak self] style, time in
                guard let self = self else { return }
                self.newQuestionTimerLabel.text = style.getTimeString(time)
                self.newQuestionTimerLabel.isHidden = false
            }
            .disposed(by: disposeBag)
        
        viewModel.votedResultObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.title = data.roomName
                self.hintText.text = data.question
                self.myNameLabel.text = "\(data.targetUser.userName) 님"
                self.mySelectedPointLabel.text = "\(data.targetUser.votedMemberCnt) / \(data.targetUser.allVoteCnt)"
                self.peopleStackView.removeAllArrangedSubviews()
                self.peopleNumStackView.removeAllArrangedSubviews()
                
                for i in 0..<data.members.count {
                    let person: UILabel = {
                        $0.text = "\(i+1). \(data.members[i].userName)"
                        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 18)
                        $0.textColor = UIColor.white
                        return $0
                    }(UILabel())
                    
                    let num: UILabel = {
                        $0.text = "\(data.members[i].votedMemberCnt) / \(data.members[i].allVoteCnt)"
                        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 18)
                        $0.textColor = UIColor.white
                        return $0
                    }(UILabel())
                    
                    self.peopleStackView.addArrangedSubview(person)
                    self.peopleNumStackView.addArrangedSubview(num)
                }
            
                let attributedString = NSMutableAttributedString(string: "지목하지 않은 사람에게 콕!  \(data.notNotedMemberCnt)명")
                let strCount = String(data.notNotedMemberCnt).count
                
                attributedString.addAttribute(.font, value: UIFont.notoSansBold(size: 16), range: NSRange(location: 0, length: attributedString.length))
                attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: 16))
                attributedString.addAttribute(.foregroundColor, value: UIColor.rgb(red: 121, green: 125, blue: 148), range: NSRange(location: 17, length: strCount+1))
                self.kokButton.setAttributedTitle(attributedString, for: .normal)
            })
            .disposed(by: disposeBag)
        
        
        
        viewModel.startTimer()
        
    }
    
//MARK: - UIComponents
    
    lazy var hintText: UILabel = {
        $0.font = UIFont.notoSansRegular(size: 18)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    lazy var peopleStackView: UIStackView = {
        $0.spacing = 4
        $0.axis = .vertical
        return $0
    }(UIStackView())
    
    lazy var peopleNumStackView: UIStackView = {
        $0.spacing = 4
        $0.axis = .vertical
        return $0
    }(UIStackView())
    
    lazy var myNameLabel: UILabel = {
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.white
        return $0
    }(UILabel())
    
    lazy var mySelectedPointLabel: UILabel = {
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
    
    lazy var kokButton: UIButton = {
        var attributedString = NSMutableAttributedString(string: "지목하지 않은 사람에게 콕!")
        attributedString.addAttribute(.font, value: UIFont.notoSansBold(size: 16), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
        $0.setAttributedTitle(attributedString, for: .normal)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 22
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        return $0
    }(UIButton())

    
//    var resultChatView = ResultChatView()
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setUIConstraints()
        bindViewModel()
    }
    
    func configureBar() {
        let backButton = UIImage(systemName: "xmark")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
    }
    
//MARK: - Set UI
    func setUI() {
        view.addSubview(hintText)
        view.addSubview(peopleStackView)
        view.addSubview(peopleNumStackView)
        view.addSubview(myNameLabel)
        view.addSubview(mySelectedPointLabel)
        view.addSubview(myResultButton)
        view.addSubview(newQuestionTimerLabel)
        view.addSubview(newQuestionButton)
        view.addSubview(kokButton)
    }
    
    func setUIConstraints() {
        hintText.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(33)
            make.leading.trailing.equalToSuperview().inset(45)
        }
        peopleStackView.snp.makeConstraints { make in
            make.top.equalTo(hintText.snp.bottom).inset(-30)
            make.leading.equalToSuperview().inset(53)
        }
        peopleNumStackView.snp.makeConstraints { make in
            make.top.equalTo(hintText.snp.bottom).inset(-30)
            make.trailing.equalToSuperview().inset(55)
        }
        myNameLabel.snp.makeConstraints { make in
            make.top.equalTo(peopleStackView.snp.bottom).inset(-40)
            make.leading.equalToSuperview().inset(53)
        }
        mySelectedPointLabel.snp.makeConstraints { make in
            make.top.equalTo(peopleNumStackView.snp.bottom).inset(-40)
            make.trailing.equalToSuperview().inset(55)
        }
        myResultButton.snp.makeConstraints { make in
            make.bottom.equalTo(kokButton.snp.top).inset(-20.8)
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
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(34.5)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(5)
        }
    }

//MARK: - Selector
    @objc func backButtonTap() {
        self.navigationController?.dismissWithNavigationPopStyle()
        self.delegate?.didChangedRoomStateFromResultVC()
    }
}

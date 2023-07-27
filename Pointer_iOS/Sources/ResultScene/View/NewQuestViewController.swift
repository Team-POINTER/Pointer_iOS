//
//  NewQuestViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/04/02.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

// 1. timeString값으로 남은 시간을 받아오고 카운트 다운 버튼 활성화 [O]
// 2. 초기에 서버에게 질문 등록하기 버튼 활성화의 유무를 받아서 바로 적용 [X]
// 3. 시간 활성화 비활성화에 따른 enum
// 4. enum 버튼 enable, backgroundColor, textColor, NSAttributedString, font,
// 5. 아예 다른 output으로 String값 - 만료시간을 뷰모델에서 계산

class NewQuestViewController: BaseViewController {
    
    let viewModel: NewQuestViewModel
    let disposeBag = DisposeBag()

//MARK: - Init
    init(viewModel: NewQuestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.roomName
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - RX
    func bindViewModel() {
        
        let input = NewQuestViewModel.Input(newQuestTextFieldEditEvent: newQuestTextField.rx.text.orEmpty.asObservable(),
                                            newQuestButtonTapEvent: newQuestButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        Observable
            .combineLatest(output.buttonIsEnable, viewModel.remainingTime)
            .bind { [weak self] style, time in
                guard let self = self else { return }
                self.newQuestButton.setAttributedTitle(style.getAttributedString(time), for: .normal)
            }
            .disposed(by: disposeBag)
        
        // 텍스트필드에 값 유무로 버튼 색상 변경
        output.newQuestTextFieldText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if text == "" {
                    self.newQuestButton.backgroundColor = nextQuestButtonStyle.disable.backgroundColor
                    self.newQuestButton.isEnabled = nextQuestButtonStyle.disable.isEnable
                } else {
                    self.newQuestButton.backgroundColor = nextQuestButtonStyle.isEnable.backgroundColor
                    self.newQuestButton.isEnabled = nextQuestButtonStyle.isEnable.isEnable
                }
            })
            .disposed(by: disposeBag)
        
        output.timeLimited
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                guard let self = self else { return}
                
                // 시간 0 시(버튼 활성화)
                if b {
                    self.newQuestTextField.isEnabled = true
                    self.newQuestTextField.textColor = .white
                    self.newQuestTextField.attributedPlaceholder = NSAttributedString(
                        string: "질문을 입력하세요.",
                        attributes: [
                            .foregroundColor: UIColor.rgb(red: 121, green: 125, blue: 148)
                        ]
                    )
                // 시간 남았을 시(버튼 비활성화)
                } else {
                    self.newQuestTextField.isEnabled = false
                    self.newQuestTextField.attributedPlaceholder = NSAttributedString(
                        string: "누군가 이미 질문을 등록했어요.",
                        attributes: [
                            .foregroundColor: UIColor.rgb(red: 121, green: 125, blue: 148)
                        ]
                    )
                }
            })
            .disposed(by: disposeBag)
        
        // 이미 질문 등록이 완료된 경우에 돌아가기 Alert
        output.backAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.dismissAlert()
                }
            })
            .disposed(by: disposeBag)
    }
    
//MARK: - UI Components
    private let questAlertLabel : UILabel = {
        $0.text = "해당 룸에 하고 싶은 질문을 작성해주세요!\n24시간마다 선착순 1명이 질문할 수 있습니다."
        $0.font = UIFont.notoSansRegular(size: 12)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var newQuestTextField: UITextField = {
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 20)
        $0.textAlignment = .center
        return $0
    }(UITextField())
    
    lazy var newQuestButton: UIButton = {
        let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
        $0.setAttributedTitle(attributedQuestionString, for: .normal)
        $0.layer.cornerRadius = 25
        $0.backgroundColor = UIColor.pointerRed.withAlphaComponent(0.6)
        $0.titleLabel?.textColor = UIColor.white.withAlphaComponent(0.6)

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
        view.addSubview(newQuestTextField)
        view.addSubview(newQuestButton)
        view.addSubview(inviteButton)
    }
    
    func setConstraints() {
        questAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(75)
            make.centerX.equalToSuperview()
        }
        newQuestTextField.snp.makeConstraints { make in
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
        bindViewModel()
    }

    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
    }
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismissAlert() {
        let backAction = PointerAlertActionConfig(title: "돌아가기", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { [weak self] _ in
            // 루트뷰로 dismiss를 해야하는가?
            self?.dismiss(animated: true)
        })
    
        let alert = PointerAlert(alertType: .alert, configs: [backAction], description: "다른 사람이 질문을 등록했습니다.")
        present(alert, animated: true)
    }
}

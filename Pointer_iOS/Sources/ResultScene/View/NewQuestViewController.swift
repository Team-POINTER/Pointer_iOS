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
// 2. 시간 활성화 비활성화에 따른 enum
// 3. enum 버튼 enable, backgroundColor, textColor, NSAttributedString, font,
// 4. 아예 다른 output으로 String값 - 만료시간을 뷰모델에서 계산
protocol NewQuestViewControllerDelegate: AnyObject {
    func didChangedResultState()
}

class NewQuestViewController: BaseViewController {
    
    let viewModel: NewQuestViewModel
    let disposeBag = DisposeBag()
    weak var delegate: NewQuestViewControllerDelegate?

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
        
        let input = NewQuestViewModel.Input(newQuestTextViewEditEvent: newQuestTextView.rx.text.orEmpty.asObservable(),
                                            newQuestButtonTapEvent: newQuestButton.rx.tap.asObservable(),
                                            inviteButtonTapEvent: inviteButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        Observable
            .combineLatest(output.buttonIsEnable, viewModel.remainingTime)
            .bind { [weak self] style, time in
                guard let self = self else { return }
                self.newQuestButton.setAttributedTitle(style.getAttributedString(time), for: .normal)
            }
            .disposed(by: disposeBag)
        
        // 텍스트뷰에 값 유무로 버튼 색상 변경
        output.newQuestTextViewText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if text == "질문을 입력하세요." || text == "누군가 이미 질문을 등록했어요." || text == "" {
                    self.newQuestButton.backgroundColor = NextQuestButtonStyle.disable.backgroundColor
                    self.newQuestButton.isEnabled = NextQuestButtonStyle.disable.isEnable
                } else {
                    self.newQuestButton.backgroundColor = NextQuestButtonStyle.isEnable.backgroundColor
                    self.newQuestButton.isEnabled = NextQuestButtonStyle.isEnable.isEnable
                }
            })
            .disposed(by: disposeBag)
        
        newQuestTextView.rx.didBeginEditing
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if (self.newQuestTextView.text == "질문을 입력하세요.") {
                    self.newQuestTextView.text = nil
                    self.newQuestTextView.textColor = .white
                }
            })
            .disposed(by: disposeBag)
        
        newQuestTextView.rx.didEndEditing
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if (self.newQuestTextView.text.count == 0) {
                    self.newQuestTextView.text = "질문을 입력하세요."
                    self.newQuestTextView.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
                }
            })
            .disposed(by: disposeBag)
        
        output.timeLimited
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                guard let self = self else { return}
                // 시간 0 시(버튼 활성화)
                if b {
                    self.newQuestTextView.isEditable = true
                    self.newQuestTextView.text = "질문을 입력하세요."
                // 시간 남았을 시(버튼 비활성화)
                } else {
                    self.newQuestTextView.isEditable = false
                    self.newQuestTextView.text = "누군가 이미 질문을 등록했어요."
                }
            })
            .disposed(by: disposeBag)
        
        // 이미 질문 등록이 완료된 경우에 돌아가기 Alert
        output.backAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                
                if type == .questionError {
                    self.dismissAlert(title: "돌아가기", description: "다른 사람이 질문을 등록했습니다.") {
                        self.navigationController?.dismissWithNavigationPopStyle()
                    }
                }
                if type == .success {
                    self.dismissAlert(title: "투표하기", description: "질문을 등록하였습니다.") {
                        self.navigationController?.dismissWithNavigationPopStyle()
                        let roomVM = RoomViewModel(roomId: self.viewModel.roomId)
                        let roomVC = RoomViewController(viewModel: roomVM)
                        
                        guard let tabBarVC = self.navigationController?.presentingViewController as? BaseTabBarController,
                              let homeNavVC = tabBarVC.viewControllers?.first as? BaseNavigationController,
                              let homeVC = homeNavVC.viewControllers.first as? HomeController else { return }
                        homeVC.viewModel.requestRoomList()
                        
                        if homeVC.viewModel.roomModel.value.isEmpty == false {
                            homeVC.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                        
                        homeNavVC.pushViewController(roomVC, animated: true)
                        return
                    }
                }
                if type == .accountError {
                    self.dismissAlert(title: "돌아가기", description: "회원 정보가 없습니다.") {
                        self.navigationController?.dismissWithNavigationPopStyle()
                    }
                }
                if type == .roomError {
                    self.dismissAlert(title: "돌아가기", description: "룸 조회에 실패하였습니다.") {
                        self.navigationController?.dismissWithNavigationPopStyle()
                    }
                }
                
                guard let tabBarVC = self.navigationController?.presentingViewController as? BaseTabBarController,
                      let homeNavVC = tabBarVC.viewControllers?.first as? BaseNavigationController,
                      let homeVC = homeNavVC.viewControllers.first as? HomeController else { return }
                homeVC.viewModel.requestRoomList()
            })
            .disposed(by: disposeBag)
        
        output.inviteButtonTap
            .bind { [weak self] viewController in
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
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
    
    private lazy var newQuestTextView: UITextView = {
        $0.backgroundColor = .clear
        $0.textAlignment = .center
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 20)
        $0.isScrollEnabled = false
        $0.delegate = self
        return $0
    }(UITextView())
    
    private lazy var newQuestButton: UIButton = {
        let attributedQuestionString = NSMutableAttributedString(string: "질문 등록하기", attributes: [.font: UIFont.notoSansBold(size: 17), .foregroundColor: UIColor.white])
        $0.setAttributedTitle(attributedQuestionString, for: .normal)
        $0.layer.cornerRadius = 25
        $0.backgroundColor = UIColor.pointerRed.withAlphaComponent(0.6)
        $0.titleLabel?.textColor = UIColor.white.withAlphaComponent(0.6)

        return $0
    }(UIButton())
    
    private let inviteButton: UIButton = {
        $0.setTitle("친구 초대하기", for: .normal)
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
        view.addSubview(newQuestTextView)
        view.addSubview(newQuestButton)
        view.addSubview(inviteButton)
    }
    
    func setConstraints() {
        questAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.leading.trailing.equalToSuperview().inset(75)
            make.centerX.equalToSuperview()
        }
        newQuestTextView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().inset(45.5)
            make.trailing.equalToSuperview().inset(45.5)
            make.height.equalTo(110)
        }
        newQuestButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(5)
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
        self.hideKeyboardWhenTappedAround()
    }

    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
    }
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.didChangedResultState()
    }
    
    func dismissAlert(title: String, description: String, completion: @escaping() -> Void) {
        let backAction = PointerAlertActionConfig(title: title, textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { [weak self] _ in
            self?.dismiss(animated: true)
            completion()
        })
    
        let alert = PointerAlert(alertType: .alert, configs: [backAction], description: description)
        present(alert, animated: true)
    }
}

//MARK: - UITextViewDelegate
extension NewQuestViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                return false // 엔터 키 입력 시 동작 X - 줄바꿈 기능 제거
            }
            return true
        }
}

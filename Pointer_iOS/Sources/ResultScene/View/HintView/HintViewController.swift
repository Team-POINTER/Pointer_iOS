//
//  HintViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class HintViewController: BaseViewController {

    let viewModel: HintViewModel
    let disposeBag = DisposeBag()

//MARK: - Init
    init(viewModel: HintViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.roomName
        self.questionLabel.text = viewModel.question
        self.selectMeLabel.text = "\(viewModel.userName) 님을 지목한 사람"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Rx
    func bindViewModel() {
        let input = HintViewModel.Input()
        let output = viewModel.transform(input: input)
        
        viewModel.showHintObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                var str = ""
                for i in 0..<data.voterNm.count {
                    str += "\(i+1). \(data.voterNm[i]) \n"
                }
                self.selectMePeopleLabel.text = str
                self.selectedMeNumber.text = "\(data.targetVotedCnt) / \(data.allVoteCnt)"
                self.hintDate.text = data.createdAt
            })
            .disposed(by: disposeBag)
        
        hintBackgroundView.rx.longPressGesture()
            .when(.began)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.longPressShowSetting()
            })
            .disposed(by: disposeBag)
            
    }
    
//MARK: - UIComponents
    var questionLabel: UILabel = {
        $0.font = UIFont.notoSansRegular(size: 19)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let hintBackgroundView: UIView = {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 28
        $0.clipsToBounds = false
        return $0
    }(UIView())
    
    var selectMeLabel: UILabel = {
        $0.font = UIFont.notoSansBold(size: 19)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var selectMePeopleLabel: UILabel = {
        $0.text = "1. Jane Cooper \n2. Ronald Richard \n3. 내가 누구게"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.textColor = UIColor.black
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    
    var selectedMeNumber: UILabel = {
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.pointerRed
        return $0
    }(UILabel())
    
    var hintDate: UILabel = {
        $0.font = UIFont.notoSansRegular(size: 13)
        $0.textColor = UIColor.black
        return $0
    }(UILabel())
    
//MARK: - Set UI
    func setUI() {
        view.addSubview(questionLabel)
        view.addSubview(hintBackgroundView)
        hintBackgroundView.addSubview(selectMeLabel)
        hintBackgroundView.addSubview(selectMePeopleLabel)
        hintBackgroundView.addSubview(selectedMeNumber)
        hintBackgroundView.addSubview(hintDate)
    }

    
    func setUIConstraints() {
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(25)
            make.leading.trailing.equalToSuperview().inset(37)
            make.centerX.equalToSuperview()
        }
        hintBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).inset(-25)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(430)
        }
        selectMeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.leading.equalToSuperview().inset(37)
        }
        selectMePeopleLabel.snp.makeConstraints { make in
            make.top.equalTo(selectMeLabel.snp.bottom).inset(-7)
            make.leading.equalToSuperview().inset(37)
        }
        selectedMeNumber.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(37)
            make.bottom.equalToSuperview().inset(30)
        }
        hintDate.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(27)
        }
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setUIConstraints()
        bindViewModel()
    }
    
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
    }
    
//MARK: - Helper
    func longPressShowSetting() {
        let report = PointerAlertActionConfig(title: "신고하기", textColor: .red) { [weak self] _ in
            self?.reportTap()
        }
        let delete = PointerAlertActionConfig(title: "삭제하기", textColor: .black) { [weak self] _ in
            print("DEBUG: 힌트 삭제")
        }
        
        let actionSheet = PointerAlert(alertType: .actionSheet, configs: [report, delete])
        present(actionSheet, animated: true)
    }

    func reportTap() {
        let spamContent = PointerAlertActionConfig(title: "스팸", textColor: .black) { [weak self] _ in
            self?.presentReportView("스팸")
        }
        let insultingContent = PointerAlertActionConfig(title: "모욕적인 문장", textColor: .black) { [weak self] _ in
            self?.presentReportView("모욕적인 문장")
        }
        let sexualHateContent = PointerAlertActionConfig(title: "성적 혐오 발언", textColor: .black) { [weak self] _ in
            self?.presentReportView("성적 혐오 발언")
        }
        let violenceOrBullyingContent = PointerAlertActionConfig(title: "폭력 또는 따돌림", textColor: .black) { [weak self] _ in
            self?.presentReportView("폭력 또는 따돌림")
        }
        let etcContent = PointerAlertActionConfig(title: "기타 사유", textColor: .black) { [weak self] _ in
            self?.presentReportView("기타 사유")
        }
        
        let actionSheet = PointerAlert(alertType: .actionSheet, configs: [spamContent, insultingContent, sexualHateContent, violenceOrBullyingContent, etcContent])
        present(actionSheet, animated: true)
    }
    
    func presentReportView(_ reason: String) {
        let reportVC = ReportViewController(reason: reason)
        let nav = UINavigationController(rootViewController: reportVC)
        present(nav, animated: true)
    }
    
//MARK: - Selector
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    

}

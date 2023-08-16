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
import FloatingPanel

class HintViewController: BaseViewController {

    let viewModel: HintViewModel
    let disposeBag = DisposeBag()
    var longPressHint = ""

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

                for i in 0..<data.voters.count {
                    let label: UILabel = {
                        $0.text = "\(i+1). \(data.voters[i].hint)"
                        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 17)
                        $0.textColor = UIColor.black
                        return $0
                    }(UILabel())
                    
                    label.rx.longPressGesture()
                        .when(.began)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] _ in
                            self?.longPressShowSetting(hint: data.voters[i].hint)
                        })
                        .disposed(by: self.disposeBag)
                    
                    selectMePeopleStackView.addArrangedSubview(label)
                }
                self.selectedMeNumber.text = "\(data.targetVotedCnt) / \(data.allVoteCnt)"
                self.hintDate.text = data.createdAt
            })
            .disposed(by: disposeBag)
    }
    
//MARK: - UIComponents
    private lazy var fpc: FloatingPanelController = {
        let controller = FloatingPanelController(delegate: self)
        controller.isRemovalInteractionEnabled = true
        controller.changePanelStyle()
        controller.layout = ReportFloatingPanelLayout()
        
        return controller
    }()
    
    lazy var scrollView: UIScrollView = {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = true
        // 이거 중요
        $0.contentSize = contentView.bounds.size
        return $0
    }(UIScrollView())
    
    lazy var contentView = UIView()
    
    var questionLabel: UILabel = {
        $0.font = UIFont.notoSansRegular(size: 19)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        $0.textAlignment = .center
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
    
    lazy var selectMePeopleStackView: UIStackView = {
        $0.spacing = 7
        $0.axis = .vertical
        return $0
    }(UIStackView())
    
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(questionLabel)
        contentView.addSubview(hintBackgroundView)
        hintBackgroundView.addSubview(selectMeLabel)
        hintBackgroundView.addSubview(selectMePeopleStackView)
        hintBackgroundView.addSubview(selectedMeNumber)
        hintBackgroundView.addSubview(hintDate)
    }

    
    func setUIConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        questionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(25)
            make.leading.trailing.equalToSuperview().inset(37)
            make.centerX.equalToSuperview()
        }
        hintBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).inset(-25)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(contentView.snp.bottom).inset(40)
        }
        selectMeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(26)
            make.leading.equalToSuperview().inset(37)
        }
        selectMePeopleStackView.snp.makeConstraints { make in
            make.top.equalTo(selectMeLabel.snp.bottom).inset(-10)
            make.leading.equalToSuperview().inset(37)
            make.bottom.equalTo(selectedMeNumber.snp.top).inset(-25)
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
    func longPressShowSetting(hint: String) {
        let report = PointerAlertActionConfig(title: "신고하기", textColor: .red) { [weak self] _ in
            self?.reportTap()
        }
        let delete = PointerAlertActionConfig(title: "삭제하기", textColor: .black) { [weak self] _ in
            print("DEBUG: 힌트 삭제")
        }
        
        longPressHint = hint
        let actionSheet = PointerAlert(alertType: .actionSheet, configs: [report, delete], title: longPressHint)
        present(actionSheet, animated: true)
    }

    func reportTap() {
        var reportConfig = [PointerAlertActionConfig]()
        
        ReportType.allCases.forEach { type in
            let config = PointerAlertActionConfig(title: type.rawValue, textColor: .black) { [weak self] _ in
                self?.presentReportView(type.rawValue)
            }
            reportConfig.append(config)
        }
        
        let actionSheet = PointerAlert(alertType: .actionSheet, configs: reportConfig, title: "신고 사유")
        present(actionSheet, animated: true)
    }
    
    // MARK: [FIX ME] 신고 하는 이름 - longPressName
    func presentReportView(_ reason: String) {
        let reportVM = ReportViewModel()
        let reportVC = ReportViewController(viewModel: reportVM)
        fpc.set(contentViewController: reportVC)
        fpc.track(scrollView: reportVC.scrollView)
        self.present(fpc, animated: true)
    }
    
//MARK: - Selector
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - FloatingPanelControllerDelegate
extension HintViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangePosition(_ fpc: FloatingPanelController) {
        if fpc.state == .full {
            
        } else {
            fpc.move(to: .full, animated: true)
        }
    }
}

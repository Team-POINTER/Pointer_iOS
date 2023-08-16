//
//  ReportViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift

final class ReportViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel: ReportViewModel
    
    func bindViewModel() {
        let input = ReportViewModel.Input(
            reportText: reportTextView.rx.text.orEmpty.asObservable(),
            submitButtonTapedEvent: submitButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.limitText
            .bind(to: reportTextView.rx.text)
            .disposed(by: disposeBag)
        
        output.reportTextCount
            .bind(to: textCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reportTextView.rx.didBeginEditing
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if (self.reportTextView.text == "포인터 팀이 조치를 취해드릴 수 있게 문제 상황을 최대한 구체적으로 설명해주세요.") {
                    self.reportTextView.text = nil
                    self.reportTextView.textColor = .black
                }
            })
            .disposed(by: disposeBag)
        
        reportTextView.rx.didEndEditing
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if (self.reportTextView.text.count == 0) {
                    self.reportTextView.text = "포인터 팀이 조치를 취해드릴 수 있게 문제 상황을 최대한 구체적으로 설명해주세요."
                    self.reportTextView.textColor = UIColor.rgb(red: 179, green: 183, blue: 205)
                }
            })
            .disposed(by: disposeBag)
        
        output.submitButtonValid
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] b in
                if b {
                    self?.submitButton.isEnabled = true
                    self?.submitButton.setTitleColor(UIColor.pointerRed, for: .normal)
                } else {
                    self?.submitButton.isEnabled = false
                    self?.submitButton.setTitleColor(UIColor.inactiveGray, for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.dismissReportView
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] b in
                if b {
                    self?.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Properties
    lazy var scrollView: UIScrollView = {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = true
        $0.contentSize = contentView.bounds.size
        return $0
    }(UIScrollView())
    
    lazy var contentView = UIView()
    
    let backView: UIView = {
        $0.backgroundColor = UIColor.rgb(red: 235, green: 236, blue: 240)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 33 / 2
        
        let image = UIImage(systemName: "xmark")?.withTintColor(UIColor.rgb(red: 130, green: 130, blue: 136), renderingMode: .alwaysOriginal)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        
        $0.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        return $0
    }(UIView())
    
    let titleLabel: UILabel = {
        $0.text = "신고"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    let submitButton: UIButton = {
        $0.setTitle("제출", for: .normal)
        $0.setTitleColor(UIColor.pointerRed, for: .normal)
        $0.titleLabel?.font = UIFont.notoSansRegular(size: 16)
        $0.isEnabled = false
        return $0
    }(UIButton())
    
    lazy var reasonLabel: UILabel = {
        $0.text = "사유 : \(viewModel.presentingReason)"
        $0.font = UIFont.notoSans(font: .notoSansKrRegular, size: 12)
        $0.textColor = UIColor.rgb(red: 87, green: 90, blue: 107)
        $0.textAlignment = .left
        return $0
    }(UILabel())
    
    lazy var textCountLabel: UILabel = {
        $0.text = "100/500"
        $0.font = UIFont.notoSans(font: .notoSansKrRegular, size: 12)
        $0.textColor = UIColor.rgb(red: 179, green: 183, blue: 205)
        $0.textAlignment = .right
        return $0
    }(UILabel())
    
    let reportTextView: UITextView = {
        $0.text = "포인터 팀이 조치를 취해드릴 수 있게 문제 상황을 최대한 구체적으로 설명해주세요."
        $0.backgroundColor = .white
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.textColor = UIColor.rgb(red: 179, green: 183, blue: 205)
        $0.isScrollEnabled = false
        return $0
    }(UITextView())
    
    // MARK: - Life Cycles
    init(viewModel: ReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }
    
    // MARK: - Set UI
    private func setUpView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(submitButton)
        contentView.addSubview(reasonLabel)
        contentView.addSubview(textCountLabel)
        contentView.addSubview(reportTextView)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        backView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(18)
            make.height.width.equalTo(33)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backView.snp.centerY)
        }
        submitButton.snp.makeConstraints { make in
            make.centerY.equalTo(backView.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(25)
            make.width.equalTo(45)
        }
        reasonLabel.snp.makeConstraints { make in
            make.top.equalTo(backView.snp.bottom).inset(-20)
            make.leading.equalToSuperview().inset(24)
            make.height.equalTo(30)
        }
        textCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(reasonLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(24)
        }
        reportTextView.snp.makeConstraints { make in
            make.top.equalTo(reasonLabel.snp.bottom).inset(-16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(contentView.snp.bottom).inset(15)
        }
    }

    // MARK: - Helper
    @objc func backButtonTap() {
        self.dismiss(animated: true)
    }
}

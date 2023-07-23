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

class ReportViewController: UIViewController {
    let reason: String
    
    let disposeBag = DisposeBag()
    let viewModel = ReportViewModel()
    
    func bindViewModel() {
        let input = ReportViewModel.Input()
        let output = viewModel.transform(input: input)
        
        reportTextView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if (self.reportTextView.text == "포인터 팀이 조치를 취해드릴 수 있게 문제 상황을 최대한 구체적으로 설명해주세요.") {
                    self.reportTextView.text = nil
                    self.reportTextView.textColor = .black
                }
            })
            .disposed(by: disposeBag)
        
        reportTextView.rx.didEndEditing
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if (self.reportTextView.text.count == 0) {
                    self.reportTextView.text = "포인터 팀이 조치를 취해드릴 수 있게 문제 상황을 최대한 구체적으로 설명해주세요."
                    self.reportTextView.textColor = UIColor.rgb(red: 179, green: 183, blue: 205)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Properties
    
    lazy var reasonLabel: UILabel = {
        $0.text = "사유 : \(reason)"
        $0.font = UIFont.notoSans(font: .notoSansKrRegular, size: 12)
        $0.textColor = UIColor.rgb(red: 87, green: 90, blue: 107)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    let reportTextView: UITextView = {
        $0.text = "포인터 팀이 조치를 취해드릴 수 있게 문제 상황을 최대한 구체적으로 설명해주세요."
        $0.backgroundColor = .white
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.textColor = UIColor.rgb(red: 179, green: 183, blue: 205)
        return $0
    }(UITextView())
    
    // MARK: - Life Cycles
    init(reason: String) {
        self.reason = reason
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureBar()
        setUIandConstraints()
        bindViewModel()
    }
    
    // MARK: - Set UI
    func setUIandConstraints() {
        view.addSubview(reasonLabel)
        view.addSubview(reportTextView)
        
        reasonLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.centerX.equalToSuperview()
        }
        reportTextView.snp.makeConstraints { make in
            make.top.equalTo(reasonLabel.snp.bottom).inset(-16)
            make.leading.trailing.equalToSuperview().inset(26)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    //MARK: - NavBar
    func configureBar() {
        navigationItem.title = "신고"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let backButton = UIImage(systemName: "chevron.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton,
                                                             size: 45,
                                                             target: self,
                                                             color: UIColor.rgb(red: 179, green: 183, blue: 205),
                                                             handler: #selector(backButtonTap))
        let reportButton = UIBarButtonItem(title: "제출", style: .done, target: self, action: #selector(reportButtonTap))
        
        reportButton.tintColor = .red

        navigationItem.leftBarButtonItem = notiButton
        navigationItem.rightBarButtonItem = reportButton
        
    }

    // MARK: - Helper
    @objc func backButtonTap() {
        self.dismiss(animated: true)
    }
    
    @objc func reportButtonTap() {
        print("DEBUG: 제출 버튼 눌림")
    }
}

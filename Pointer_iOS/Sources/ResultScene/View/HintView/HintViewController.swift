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
        viewModel.showHintObservable
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                
                self.selectedMeNumber.text = "\(data.targetVotedCnt) / \(data.allVoteCnt)"
                self.hintDate.text = data.createdAt
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
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    

}

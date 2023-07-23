//
//  TermsViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TermsViewController: BaseViewController {

    var disposeBag = DisposeBag()
    let viewModel: TermsViewModel
    
    init(viewModel: TermsViewModel, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.viewModel = viewModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - RX
    func bindViewModel() {
        let input = TermsViewModel.Input(allAllowTapEvent: checkBoxAll.rx.tap.asObservable(), overAgeAllowTapEvent: checkBox1.rx.tap.asObservable(), serviceAllowTapEvent: checkBox2.rx.tap.asObservable(), privateInfoAllowTapEvent: checkBox3.rx.tap.asObservable(), marketingInfoAllowTapEvent: checkBox4.rx.tap.asObservable(), nextButtonTapEvent: nextButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.allAllow
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.checkBoxAll.isSelected = b
                } else {
                    self?.checkBoxAll.isSelected = b
                }
            })
            .disposed(by: disposeBag)
        
        output.overAgeAllow
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.checkBox1.isSelected = b
                } else {
                    self?.checkBox1.isSelected = b
                }
            })
            .disposed(by: disposeBag)

        output.serviceAllow
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.checkBox2.isSelected = b
                } else {
                    self?.checkBox2.isSelected = b
                }
            })
            .disposed(by: disposeBag)

        output.privateInfoAllow
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.checkBox3.isSelected = b
                } else {
                    self?.checkBox3.isSelected = b
                }
            })
            .disposed(by: disposeBag)

        output.marketingInfoAllow
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.checkBox4.isSelected = b
                } else {
                    self?.checkBox4.isSelected = b
                }
            })
            .disposed(by: disposeBag)
        
        output.nextButtonValid
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.nextButton.isEnabled = b
                    self?.nextButton.backgroundColor = UIColor.pointerRed
                } else {
                    self?.nextButton.isEnabled = b
                    self?.nextButton.backgroundColor = UIColor.rgb(red: 87, green: 90, blue: 107)
                }
            })
            .disposed(by: disposeBag)
        
        output.nextButtonTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewController in
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
//MARK: - UIComponents
    private let serviceLabel: UILabel = {
        $0.text = "서비스 이용동의"
        $0.textColor = .white
        $0.font = UIFont.notoSansBold(size: 20)
        return $0
    }(UILabel())
    
    var checkBoxAll: UIButton = {
        $0.setImage(UIImage(named: "termCheck"), for: .selected)
        $0.setImage(UIImage(named: "termUnCheck"), for: .normal)
        return $0
    }(UIButton())
    
    private let TermAllLabel: UILabel = {
        $0.text = "약관 전체동의"
        $0.textColor = .white
        $0.font = UIFont.notoSansBold(size: 16)
        return $0
    }(UILabel())
    
    var checkBox1: UIButton = {
        $0.setImage(UIImage(named: "termCheck"), for: .selected)
        $0.setImage(UIImage(named: "termUnCheck"), for: .normal)
        return $0
    }(UIButton())
    
    private let Label1: UILabel = {
        $0.text = "(필수) 만 14세 이상입니다."
        $0.textColor = .white
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        return $0
    }(UILabel())
    
    
    var checkBox2: UIButton = {
        $0.setImage(UIImage(named: "termCheck"), for: .selected)
        $0.setImage(UIImage(named: "termUnCheck"), for: .normal)
        return $0
    }(UIButton())
    
    private let Label2: UILabel = {
        $0.text = "(필수) 서비스 이용 약관"
        $0.textColor = .white
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        return $0
    }(UILabel())
    
    var termBtn1: UIButton = {
        $0.tintColor = UIColor.rgb(red: 179, green: 183, blue: 205)
        $0.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        return $0
    }(UIButton())
    
    var checkBox3: UIButton = {
        $0.setImage(UIImage(named: "termCheck"), for: .selected)
        $0.setImage(UIImage(named: "termUnCheck"), for: .normal)
        return $0
    }(UIButton())
    
    private let Label3: UILabel = {
        $0.text = "(필수) 개인정보 처리방침"
        $0.textColor = .white
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        return $0
    }(UILabel())
    
    var termBtn2: UIButton = {
        $0.tintColor = UIColor.rgb(red: 179, green: 183, blue: 205)
        $0.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        return $0
    }(UIButton())
    
    var checkBox4: UIButton = {
        $0.setImage(UIImage(named: "termCheck"), for: .selected)
        $0.setImage(UIImage(named: "termUnCheck"), for: .normal)
        return $0
    }(UIButton())
    
    private let Label4: UILabel = {
        $0.text = "(선택) 마케팅 정보 수신동의"
        $0.textColor = .white
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        return $0
    }(UILabel())
    
    var termBtn3: UIButton = {
        $0.tintColor = UIColor.rgb(red: 179, green: 183, blue: 205)
        $0.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        return $0
    }(UIButton())
    
    var nextButton: UIButton = {
        $0.backgroundColor = UIColor.rgb(red: 87, green: 90, blue: 107)
        $0.titleLabel?.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.titleLabel?.textColor = UIColor.white
        $0.layer.cornerRadius = 16
        $0.setTitle("확인", for: .normal)
        $0.isEnabled = false
        return $0
    }(UIButton())
    
    private let sectionLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 87, green: 90, blue: 107)
        return view
    }()

    
//MARK: - set UI
    func setUI() {
        view.addSubview(serviceLabel)
        view.addSubview(checkBoxAll)
        view.addSubview(TermAllLabel)
        view.addSubview(nextButton)
        view.addSubview(sectionLine)
        view.addSubview(Label1)
        view.addSubview(Label2)
        view.addSubview(Label3)
        view.addSubview(Label4)
        view.addSubview(checkBox1)
        view.addSubview(checkBox2)
        view.addSubview(checkBox3)
        view.addSubview(checkBox4)
        view.addSubview(termBtn1)
        view.addSubview(termBtn2)
        view.addSubview(termBtn3)
    }
    
    func setUIConstraints() {
        serviceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(25)
            make.leading.equalToSuperview().inset(32)
        }
        checkBoxAll.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.top.equalTo(serviceLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(35)
        }
        TermAllLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkBoxAll.snp.trailing).offset(12)
            make.top.equalTo(serviceLabel.snp.bottom).offset(30)
            make.centerY.equalTo(checkBoxAll.snp.centerY)
        }
        sectionLine.snp.makeConstraints { make in
            make.top.equalTo(TermAllLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(1)
        }
        checkBox1.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.top.equalTo(sectionLine.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(35)
        }
        Label1.snp.makeConstraints { make in
            make.leading.equalTo(checkBox1.snp.trailing).offset(12)
            make.top.equalTo(sectionLine.snp.bottom).offset(30)
            make.centerY.equalTo(checkBox1.snp.centerY)
        }
        checkBox2.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.top.equalTo(checkBox1.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(35)
        }
        Label2.snp.makeConstraints { make in
            make.leading.equalTo(checkBox2.snp.trailing).offset(12)
            make.top.equalTo(Label1.snp.bottom).offset(30)
            make.centerY.equalTo(checkBox2.snp.centerY)
        }
        termBtn1.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(Label2.snp.centerY)
        }
        checkBox3.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.top.equalTo(checkBox2.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(35)
        }
        Label3.snp.makeConstraints { make in
            make.leading.equalTo(checkBox3.snp.trailing).offset(12)
            make.top.equalTo(Label2.snp.bottom).offset(30)
            make.centerY.equalTo(checkBox3.snp.centerY)
        }
        termBtn2.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(Label3.snp.centerY)
        }
        checkBox4.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.top.equalTo(checkBox3.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(35)
        }
        Label4.snp.makeConstraints { make in
            make.leading.equalTo(checkBox4.snp.trailing).offset(12)
            make.top.equalTo(Label3.snp.bottom).offset(30)
            make.centerY.equalTo(checkBox4.snp.centerY)
        }
        termBtn3.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(Label4.snp.centerY)
        }
        nextButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(33)
            make.leading.trailing.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(65)
        }
    }
    
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setUIConstraints()
        bindViewModel()
    }
    
}

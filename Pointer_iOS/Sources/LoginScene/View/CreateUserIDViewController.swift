//
//  CreateUserIDViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/07/01.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxKeyboard

class CreateUserIDViewController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    let viewModel: CreateUserIDViewModel
    private let extra = UIApplication.shared.windows.first!.safeAreaInsets.bottom
    private lazy var validateIdView = ValidateIdView(ValidateIdViewModel(authResultModel: viewModel.authResultModel))
    
    private var nextButton: UIButton = {
        $0.titleLabel?.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.titleLabel?.textColor = UIColor.white
        $0.layer.cornerRadius = 16
        $0.setTitle("확인", for: .normal)
        return $0
    }(UIButton())
    
    init(viewModel: CreateUserIDViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        configureBar()
    }
    
//MARK: - RX
    func bindViewModel() {
        let input = CreateUserIDViewModel.Input(
            nextButtonTapEvent: nextButton.rx.controlEvent(.touchUpInside).asObservable(),
            validateIdViewModel: validateIdView.viewModel)
        
        let output = viewModel.transform(input: input)
     
        output.nextButtonValid
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.nextButton.isEnabled = true
                    self?.nextButton.backgroundColor = UIColor.pointerRed
                } else {
                    self?.nextButton.isEnabled = false
                    self?.nextButton.backgroundColor = UIColor.rgb(red: 87, green: 90, blue: 107)
                }
            })
            .disposed(by: disposeBag)
        
        output.didProcessDone
            .bind { [weak self] _ in
                guard let self = self,
                      let tabBarVc = self.presentingViewController as? BaseTabBarController else { return }
                self.dismiss(animated: true) {
                    tabBarVc.configureAuth()
                }
            }
            .disposed(by: disposeBag)
        
        output.errorAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] alert in
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.visibleHeight
            .skip(1)    // 초기 값 버리기
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else { return }
                // 키보드가 바닥일 때
                if keyboardVisibleHeight == 0 {
                    UIView.animate(withDuration: 0) {
                        self.nextButton.snp.updateConstraints {
                            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
                        }
                    }
                // 키보드가 올라왔을 때
                } else {
                    UIView.animate(withDuration: 0) {
                        self.nextButton.snp.updateConstraints {
                            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardVisibleHeight - self.extra)
                        }
                    }
                }
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
//MARK: - set UI
    func setupUI() {
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(65)
        }
        
        view.addSubview(validateIdView)
        validateIdView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(nextButton.snp.top)
        }
    }

//MARK: - NavigationBar
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
        self.title = "사용자 아이디 생성"
    }
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}




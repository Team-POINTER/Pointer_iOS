//
//  MyResultViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MyResultViewController: BaseViewController {
//MARK: - properties
    let disposeBag = DisposeBag()
    var viewModel: MyResultViewModel
    var hintVC = UIViewController()
    
//MARK: - Init
    init(viewModel: MyResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.roomName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Rx
    func bindViewModel() {
        let input = MyResultViewModel.Input(
            hintTableViewItemSelected: hintTableView.rx.itemSelected.asObservable(),
            hintTableViewModelSelected: hintTableView.rx.modelSelected(TotalQuestionResultData.self).asObservable()
        )
        let output = viewModel.transform(input: input)
        
        viewModel.myResultObservable
            .observe(on: MainScheduler.instance)
            .bind(to: hintTableView.rx.items) { tableView, index, item in
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MyResultTableViewCell.identifier, for: IndexPath(row: index, section: 0)) as? MyResultTableViewCell
                else { return UITableViewCell() }
                cell.selectionStyle = .none
                cell.result = item
                
                return cell
            }
            .disposed(by: disposeBag)
        
        output.hintTableViewSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewController in
                guard let self = self else { return }
                self.hintVC = viewController
                self.usePointAlert(title: "포인트 0개 사용", description: "포인트 0개를 사용하여 나를 지목한 사람의 힌트를 확인하시겠어요?") {
                    
                }
            })
            .disposed(by: disposeBag)
    }
    
//MARK: - UIComponents
    private let hintAlertLabel : UILabel = {
        $0.text = "해당 질문에서 나를 지목한 사람의 힌트를 확인하려면 클릭!"
        $0.font = UIFont.notoSansRegular(size: 12)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    let hintTableView : UITableView = {
        $0.backgroundColor = .clear
        $0.register(MyResultTableViewCell.self, forCellReuseIdentifier: MyResultTableViewCell.identifier)
        $0.bounces = false
        $0.allowsSelection = true
        return $0
    }(UITableView())

//MARK: - set UI    
    func setUI() {
        view.addSubview(hintAlertLabel)
        view.addSubview(hintTableView)
    }

    
    func setUIConstraints() {
        hintAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
        hintTableView.snp.makeConstraints { make in
            make.top.equalTo(hintAlertLabel.snp.bottom).inset(-2.6)
            make.leading.trailing.equalToSuperview().inset(12.5)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(Device.width - 25)
        }
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setUIConstraints()
        configureBar()
        hintTableView.delegate = self
        bindViewModel()
    }
    
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
    }
    
//MARK: - Functions
    func usePointAlert(title: String, description: String, completion: @escaping() -> Void) {
        let backAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { _ in
            completion()
        })
        
        let useAction = PointerAlertActionConfig(title: "사용하기", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.pushViewController(self.hintVC, animated: true)
            //MARK: 업데이트 이후 포인트 확인과 부족했을 시 Alert 분기 처리 추가
            completion()
        })
    
        let alert = PointerAlert(alertType: .alert, configs: [backAction, useAction], title: title, description: description)
        present(alert, animated: true)
    }
    
//MARK: - Handler
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension MyResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}

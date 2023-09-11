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
        
        output.checkedPointResult
            .bind { [weak self] model in
                guard let self = self,
                      let model = model else { return }
                
                self.present(self.viewModel.usePointAlert(title: "포인트 \(model.point)개 사용",
                                                     description: "포인트를 \(model.point)개 사용하여 나를 지목한 사람의 힌트를 확인하시겠어요?",
                                                     point: model.point), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.lackedPointResult
            .bind { [weak self] b in
                guard let self = self else { return }
                if b {
                    self.present(self.viewModel.moveToAppStoreAlert(title: "포인트가 부족해요", description: "포인트를 샵으로 충전하러 가서 나를 지목한 사람을 확인할까요?"), animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        output.usedPointResult
            .bind { [weak self] viewController in
                guard let self = self,
                      let vc = viewController else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
        $0.showsVerticalScrollIndicator = false
        return $0
    }(UITableView())

//MARK: - set UI    
    func setUI() {
        view.addSubview(hintAlertLabel)
        view.addSubview(hintTableView)
        
        hintTableView.delegate = self
    }

    
    func setUIConstraints() {
        hintAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
        hintTableView.snp.makeConstraints { make in
            make.top.equalTo(hintAlertLabel.snp.bottom).inset(-3)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setUIConstraints()
        configureBar()
        bindViewModel()
    }
    
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
    }
    
//MARK: - Functions

    
//MARK: - Handler
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension MyResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.height // 스크롤뷰의 전체 높이
        let contentSizeHeight = scrollView.contentSize.height // 전체 콘텐츠 영역의 높이
        let offset = scrollView.contentOffset.y // 클릭 위치
        let reachedBottom = (offset > contentSizeHeight - height) // (클릭 지점 + 스크롤뷰 높이 == 전체 컨텐츠 높이) -> Bool
        
        if reachedBottom && (contentSizeHeight > height) { // 스크롤이 바닥에 닿았다면 & 컨텐츠가 스크롤 가능한 높이일 때
            viewModel.reFetchtotalQuestionRequest()
        }
    }
}

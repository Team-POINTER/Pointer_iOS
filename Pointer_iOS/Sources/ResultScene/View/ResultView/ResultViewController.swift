//
//  ResultViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FloatingPanel

class ResultViewController: BaseViewController {
    
    var viewModel = ResultViewModel()
    let disposeBag = DisposeBag()
    
//MARK: - Rx
    func bindViewModel() {
        
        resultView.myResultButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(MyResultViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    
    }
    
//MARK: - UIComponents
    var scrollView: UIScrollView = {
        $0.bounces = false
        return $0
    }(UIScrollView())
    
    var resultView = ResultView()
    var resultChatView = ResultChatView()
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setUIConstraints()
        bindViewModel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chatTaped))
        resultChatView.view.addGestureRecognizer(tapGesture)
        resultChatView.view.isUserInteractionEnabled = true
    }
    
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
        
        self.title = "룸 이름"
        // - navigation bar title 색상 변경
    }
    
//MARK: - Set UI
    func setUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(resultView)
        scrollView.addSubview(resultChatView)
    }
    
    func setUIConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        resultView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }
        resultChatView.snp.makeConstraints { make in
            make.top.equalTo(resultView.kokView.snp.bottom).inset(-30)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalTo(UIScreen.main.bounds.width - 32)
            make.height.equalTo(135)
        }
    }
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func chatTaped() {
        let resultChatViewController = FloatingChatViewController(contentViewController: MyViewController())
        present(resultChatViewController, animated: true)
    }
    
    
}

//MARK: - ScrollableViewController: 클라이언트 코드에서 해당 프로토콜에 명시된 인터페이스에 접근 - 여기서 바꿔야 함!!
final class MyViewController: UIViewController, ScrollableViewController {
    
    private let tableView: SelfSizingTableView = {
        $0.allowsSelection = false
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.indicatorStyle = .black
        $0.estimatedRowHeight = 34.0
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return $0
    }(SelfSizingTableView(maxHeight: UIScreen.main.bounds.height * 0.7))
    
    var scrollView: UIScrollView {
        tableView
    }
        
    init() {
        super.init(nibName: nil, bundle: nil)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUpView() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.dataSource = self
    }
}

extension MyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "cell\(indexPath.row)"
        return cell
    }
}

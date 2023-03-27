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
        print("bindViewModel called")
        
        myResultButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                print("ssdasdas")
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
    
    var hintText: UILabel = {
        $0.text = "한 20년 뒤 미래에 가장 돈을 잘 벌 것 같은 사람은 누구인가? 최대 공백포함 45"
        $0.font = UIFont.notoSansRegular(size: 18)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var selectedPeopleLabel: UILabel = {
        $0.text = " 1. Jane Cooper\n 2. Ronald Richaaaaaard\n 3. Bessie Cooper\n 4. Jane Cooper\n 5. Ronald Richaaaaaard\n 6. Bessie Cooper\n"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 18)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var selectedPointLabel: UILabel = {
        $0.text = "10 / 20\n  4 / 20\n  3 / 20\n  1 / 20\n  1 / 20\n  1 / 20\n"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 18)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var myNameLabel: UILabel = {
        $0.text = "포인터 님"
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.white
        return $0
    }(UILabel())
    
    var mySelectedPointLabel: UILabel = {
        $0.text = "3 / 20"
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.pointerRed
        return $0
    }(UILabel())
    
    let myResultButton : UIButton = {
        $0.setTitle("나의 결과보기", for: .normal)
        $0.setTitleColor(UIColor.pointerRed, for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 16)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 22
        return $0
    }(UIButton())
    
    var newQuestionTimerLabel: UILabel = {
        $0.text = "22:23:34"
        $0.font = UIFont.notoSansRegular(size: 14)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    let newQuestionButton : UIButton = {
        $0.setTitle("새 질문 등록하기", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 16)
        $0.backgroundColor = UIColor.pointerRed
        $0.layer.cornerRadius = 22
        return $0
    }(UIButton())
    
    let kokView: UIView = {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 22
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        return $0
    }(UIView())
    
    let kokLabel: UILabel = {
        $0.text = "지목하지 않은 사람에게 콕!"
        $0.font = UIFont.notoSansBold(size: 16)
        $0.textColor = UIColor.white
        return $0
    }(UILabel())
    
    var kokNumberLabel: UILabel = {
        $0.text = "4명"
        $0.font = UIFont.notoSansBold(size: 16)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        return $0
    }(UILabel())
    
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
        scrollView.addSubview(hintText)
        scrollView.addSubview(selectedPeopleLabel)
        scrollView.addSubview(selectedPointLabel)
        scrollView.addSubview(myNameLabel)
        scrollView.addSubview(mySelectedPointLabel)
        scrollView.addSubview(myResultButton)
        scrollView.addSubview(newQuestionTimerLabel)
        scrollView.addSubview(newQuestionButton)
        scrollView.addSubview(kokView)
        kokView.addSubview(kokLabel)
        kokView.addSubview(kokNumberLabel)
        view.addSubview(resultChatView)
    }
    
    func setUIConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hintText.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(33)
            make.leading.trailing.equalToSuperview().inset(45)
        }
        selectedPeopleLabel.snp.makeConstraints { make in
            make.top.equalTo(hintText.snp.bottom).inset(-30)
            make.leading.equalToSuperview().inset(53)
        }
        selectedPointLabel.snp.makeConstraints { make in
            make.top.equalTo(hintText.snp.bottom).inset(-30)
            make.trailing.equalToSuperview().inset(55)
        }
        myNameLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedPeopleLabel.snp.bottom).inset(15)
            make.leading.equalToSuperview().inset(60)
        }
        mySelectedPointLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedPointLabel.snp.bottom).inset(15)
            make.trailing.equalToSuperview().inset(55)
        }
        myResultButton.snp.makeConstraints { make in
            make.top.equalTo(myNameLabel.snp.bottom).inset(-60)
            make.leading.equalToSuperview().inset(34.5)
            make.width.equalTo(145)
            make.height.equalTo(44)
        }
        newQuestionButton.snp.makeConstraints { make in
            make.centerY.equalTo(myResultButton.snp.centerY)
            make.trailing.equalToSuperview().inset(34.5)
            make.width.equalTo(145)
            make.height.equalTo(44)
        }
        newQuestionTimerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(newQuestionButton.snp.top).inset(-5)
            make.centerX.equalTo(newQuestionButton.snp.centerX)
        }
        kokView.snp.makeConstraints { make in
            make.top.equalTo(myResultButton.snp.bottom).inset(-20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(34.5)
            make.height.equalTo(50)
        }
        kokLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(55)
        }
        kokNumberLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(kokLabel.snp.trailing).inset(-10)
        }

        resultChatView.snp.makeConstraints { make in
            make.top.equalTo(kokView.snp.bottom).inset(-30)
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
    }(SelfSizingTableView(maxHeight: UIScreen.main.bounds.height * 0.62))
    
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


//
//  RoomViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/12.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay

//MARK: 비동기로 처리해야할 부분
// 1. hint 입력했을 시 글자수 20자 제한 [O]
// 2. 테이블 뷰에서 셀들 선택 후 point 하는 부분 [X]
// 3. 링크로 초대하기 부분 [X]

//MARK: 처리해야할 부분
// 1. 테이블 뷰 더미데이터 만들기 [O] -> API 연동 [X]
// 2. 룸에서 Point를 누른 사람들을 selectPeople에 담아서 fontColor변경 후 줄바꿈하여 출력[X]
// 3. 글씨체 적용 [O]
// 4. Point 버튼 이미지로 처리함[O] -> tableView 셀 클릭후 데이터 입력 시 point 버튼 활성화 [X]
// 5. navigationBar titleColor [X], LeftBarItem 추가 [O]

class RoomViewController: BaseViewController {
    
//MARK: - Components
//    var viewModel = RoomViewModel?
    var tableViewHeight = 0 // 데이터의 개수 * 55 해서 tableView height 값 넣기[x] - 86번쨰 줄
    let disposeBag = DisposeBag()
    
    var cellChecked = [Int]()
    
    func bindViewModel(viewModel: RoomViewModel = RoomViewModel(maxNumber: 20)) {
        // hintTextField 입력 값 20자 제한
        roomTopView.hintTextField.rx.text.orEmpty
            .bind(to: viewModel.hintTextObservable)
            .disposed(by: disposeBag)
        
        viewModel.currentLength
            .emit { [weak self] str in
                self?.roomTopView.hintTextCount.text = str
            }
            .disposed(by: disposeBag)
        
        viewModel.isEditable
            .emit(onNext: { [weak self] isEditable in
                if !isEditable {
                    self?.roomTopView.hintTextField.text = String(self?.roomTopView.hintTextField.text?.dropLast() ?? "")
                }
            })
            .disposed(by: disposeBag)
    }
    
//MARK: - UIComponents
    private let scrollView : UIScrollView = {
        $0.bounces = false
        return $0
    }(UIScrollView())
    
    let roomTopView = RoomTopView()
    
    private let stackView: UIStackView = {
        $0.axis = .vertical
        return $0
    }(UIStackView())
    
    private let peopleTableView : UITableView = {
        $0.backgroundColor = .clear
        $0.register(RoomPeopleTableViewCell.self, forCellReuseIdentifier: RoomPeopleTableViewCell.identifier)
        $0.bounces = false
        $0.isScrollEnabled = false
        return $0
    }(UITableView())
    
    private let roomBottomView = RoomBottomView()
    
//MARK: - set UI
    
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
    }
    
    func setUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(roomTopView)
        stackView.addArrangedSubview(peopleTableView)
        stackView.addArrangedSubview(roomBottomView)
    }
    
    func setUIConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        stackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        roomTopView.snp.makeConstraints { make in
            make.height.equalTo(520)
        }
        peopleTableView.snp.makeConstraints { make in
            make.height.equalTo(600)
        }
        roomBottomView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
    }
    
    func didScrollFunc() {
        scrollView.delegate = self
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "룸 이름"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        configureBar()
        setUI()
        setUIConstraints()
        didScrollFunc()
        bindViewModel()
    }
    
    
    @objc func backButtonTap() {
        
    }
}
//MARK: - TableView
extension RoomViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomPeopleTableViewCell.identifier, for: indexPath) as? RoomPeopleTableViewCell else { return UITableViewCell() }
        
        cell.isSelected = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 선택시 회색화면 지우기
        print("cell indexPath = \(indexPath)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as? RoomPeopleTableViewCell
        // star 체크표시 만들
        if cell?.pointStar.isHidden == true {
            cell?.pointStar.isHidden = false
            cellChecked.append(indexPath.row)
        } else {
            cell?.pointStar.isHidden = true
            cellChecked.remove(at: indexPath.row)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let remainingScrollHeight = scrollView.contentSize.height - scrollView.frame.size.height
            let isBottomReached = scrollView.contentOffset.y >= remainingScrollHeight
            peopleTableView.isScrollEnabled = isBottomReached
        }
    }

}
//MARK: - RX
private extension RoomViewController {
        
//        let input = RoomViewModel.Input(
//            hintTextDidEditEvent: roomTopView.hintTextField.rx.text.orEmpty.asObservable(),
//            peopleDidTapEvent: roomTopView.peopleTableView.rx.cellForRow(at: IndexPath).asObservable(),
//            pointButtonActive: roomTopView.pointerButton.rx.isEnabled.asObservable(),
//            pointButtonTapEvent: roomTopView.pointerButton.rx.tap.asObservable(),
//            inviteButtonTapEvent: roomBottomView.inviteButton.rx.tap.asObservable()
//        )
//
//        let output = self.viewModel?.transform(input: input, output: <#T##V#>)
//
//
//        roomTopView.hintTextField.rx.text.orEmpty
//            .bind(to: viewModel.hintTextObservable)
//            .disposed(by: disposeBag)
//
//        viewModel.currentLength
//            .emit { [weak self] str in
//                self?.roomTopView.hintTextCount.text = str
//            }
//            .disposed(by: disposeBag)
//
//        viewModel.isEditable
//            .emit(onNext: { [weak self] isEditable in
//                if !isEditable {
//                    self?.roomTopView.hintTextField.text = String(self?.roomTopView.hintTextField.text?.dropLast() ?? "")
//                }
//            })
//            .disposed(by: disposeBag)
//    }
}

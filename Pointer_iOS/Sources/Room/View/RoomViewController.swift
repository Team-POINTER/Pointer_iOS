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

//MARK: 비동기로 처리해야할 부분
// 1. hint 입력했을 시 글자수 20자 제한 [O]
// 2. 테이블 뷰에서 셀들 선택 후 point 하는 부분 [X]
// 3. 링크로 초대하기 부분 [X]

//MARK: 처리해야할 부분
// 1. 테이블 뷰 더미데이터 만들기 [O] -> API 연동 [X]
// 2. 룸에서 Point를 누른 사람들을 selectPeople에 담아서 fontColor변경 후 줄바꿈하여 출력[X]
// 3. 글씨체 적용 [O]
// 4. Point 버튼 이미지로 처리함[O] -> tableView 셀 클릭후 데이터 입력 시 point 버튼 활성화 [X]
// 5. navigationBar titleColor, LeftBarItem 추가 [X]

class RoomViewController: BaseViewController {
    
//MARK: - Components

    var tableViewHeight = 0 // 데이터의 개수 * 55 해서 tableView height 값 넣기[x]
    let disposeBag = DisposeBag()
    
    var viewModel = RoomViewModel()
    
    var cellChecked = [0,0,0,0,0,0,0,0,0,0]
    
//MARK: - Rx
    func bindViewModel() {
        
        roomTopView.hintTextField.rx.text
            .orEmpty
            .bind(to: viewModel.hintTextFieldText)
            .disposed(by: disposeBag)
        
        roomTopView.hintTextField.rx.text
            .orEmpty
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { text in
                self.hintTextLimit(text)
            })
            .disposed(by: disposeBag)
        
        roomTopView.hintTextField.rx.text
            .orEmpty
            .map{ "\($0.count)" }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { count in
                self.roomTopView.hintTextCount.text = "\(count)/20"
            })
            .disposed(by: disposeBag)
        
// - tableView bind
        viewModel.roomObservable
            .observe(on: MainScheduler.instance)
            .bind(to: peopleTableView.rx.items(cellIdentifier: "RoomPeopleTableViewCell", cellType: RoomPeopleTableViewCell.self)) { index, item, cell in
                cell.nameLabel.text = item.name
                cell.pointStar.isHidden = item.isHidden
                
            }.disposed(by: disposeBag)
        
        
        
        Observable
            .zip(peopleTableView.rx.itemSelected, peopleTableView.rx.modelSelected(RoomModel.self))
            .bind { [weak self] indexPath, model in
                self?.peopleTableView.deselectRow(at: indexPath, animated: false)
                print("Selected \(model) at \(indexPath)")
                let cell = self?.peopleTableView.cellForRow(at: indexPath) as? RoomPeopleTableViewCell
                
                // point 체크 이미지[O] & 배열 추가해야함 [O]
                if cell?.clickCount == 1 {
                    self?.cellChecked[indexPath.row] = 0
                    cell?.clickCount = 0
                    print("\(String(describing: self?.cellChecked))")
                } else {
                    cell?.clickCount += 1
                    self?.cellChecked[indexPath.row] = 1
                    print("\(String(describing: self?.cellChecked))")
                }
            }
            .disposed(by: disposeBag)
        
        
// - point button bind
        // cellChecked 배열에 있는 Observer와 hintTextEdit을 combineLast로 묶어서 처리 [X]
        // 배열 값이 변경되는 옵저버 선언해야함 [X]
//        roomTopView.pointerButton.rx.tap
//            .bind(to: viewModel.pointButtonTap)
//            .disposed(by: disposeBag)
        
        
            
    }
    
//MARK: - helper
    // 텍스트 20자 제한
    private func hintTextLimit(_ str: String) {
        if str.count > 20 {
            let index = str.index(str.startIndex, offsetBy: 20)
            self.roomTopView.hintTextField.text = String(str[..<index])
        }
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
        
        self.title = "룸 이름"
        // - navigation bar title 색상 변경
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
            make.height.equalTo(400)
        }
        roomBottomView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
    }
    
    func didScrollFunc() {
        scrollView.delegate = self
        peopleTableView.delegate = self
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setUIConstraints()
        didScrollFunc()
        bindViewModel()
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @objc func backButtonTap() {
        
    }
    
    
}


//MARK: - TableView
extension RoomViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let remainingScrollHeight = scrollView.contentSize.height - scrollView.frame.size.height
            let isBottomReached = scrollView.contentOffset.y >= remainingScrollHeight
            peopleTableView.isScrollEnabled = isBottomReached
        }
    }

}


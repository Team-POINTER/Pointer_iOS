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
// 2. 테이블 뷰에서 셀들 선택 후 point 하는 부분 [O]
// 3. 링크로 초대하기 부분 [O] -> API 연동 [X]
// 4. Point 버튼 클릭 부분 [O] -> API 연동 [X]

//MARK: 처리해야할 부분
// 1. 테이블 뷰 더미데이터 만들기 [O] -> API 연동 [X]
// 2. 글씨체 적용 [O]
// 3. Point 버튼 이미지로 처리함[O] -> tableView 셀 클릭후 데이터 입력 시 point 버튼 활성화 [O]
// 4. navigationBar titleColor, LeftBarItem 추가 [O]
// 5. 셀을 클릭 시 ViewModel에 배열로 클릭한 셀의 이름들이 저장됨 -> 삭제 시 이름이 똑같다면 문제가 생김(해결[X])

class RoomViewController: BaseViewController {
    
//MARK: - Components

    var disposeBag = DisposeBag()
    var viewModel = RoomViewModel()
    
//MARK: - Rx
    func bindViewModel() {
        let people: [RoomModel] = [
            RoomModel(name: "로미오미오", isHidden: true),
            RoomModel(name: "김씨", isHidden: true),
            RoomModel(name: "냠남", isHidden: true),
            RoomModel(name: "김지수지수", isHidden: true),
            RoomModel(name: "언씨", isHidden: true),
            RoomModel(name: "박현준현준", isHidden: true),
            RoomModel(name: "김씨", isHidden: true),
            RoomModel(name: "냠남", isHidden: true),
            RoomModel(name: "곽민섭민섭", isHidden: true),
            RoomModel(name: "언씨", isHidden: true),
            RoomModel(name: "최성현성현", isHidden: true)
        ]
        
        viewModel.roomObservable.accept(people)
        
        let input = RoomViewModel.Input(hintTextEditEvent: roomTopView.hintTextField.rx.text.orEmpty.asObservable())
        
        let output = viewModel.transform(input: input)
        
// - TextField bind
        output.hintTextFieldCount
            .bind(to: roomTopView.hintTextCount.rx.text)
            .disposed(by: disposeBag)
        
        output.hintTextValid
            .bind(to: roomTopView.hintTextField.rx.text)
            .disposed(by: disposeBag)
            
// - hintText bind
        output.selectPeople
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                if text == "" {
                    self?.roomTopView.selectPeople.text = "선택하지 않았어요"
                    self?.roomTopView.selectPeople.textColor = UIColor.rgb(red: 87, green: 90, blue: 107)
                } else {
                    self?.roomTopView.selectPeople.text = text
                    self?.roomTopView.selectPeople.textColor = UIColor.white
                }
            })
            .disposed(by: disposeBag)
        
// - tableView bind
        viewModel.roomObservable
            .observe(on: MainScheduler.instance)
            .bind(to: peopleTableView.rx.items(cellIdentifier: "RoomPeopleTableViewCell", cellType: RoomPeopleTableViewCell.self)) { index, item, cell in
                cell.nameLabel.text = item.name
                cell.pointStar.isHidden = item.isHidden
                
            }.disposed(by: disposeBag)
        
//- tableView cell tapped
        Observable
            .zip(peopleTableView.rx.itemSelected, peopleTableView.rx.modelSelected(RoomModel.self))
            .bind { [weak self] indexPath, model in
                self?.peopleTableView.deselectRow(at: indexPath, animated: false)
                print("Selected \(model) at \(indexPath)")
                let cell = self?.peopleTableView.cellForRow(at: indexPath) as? RoomPeopleTableViewCell
                
                // point 체크 이미지[O] & 배열 추가해야함 [O]
                if cell?.clickCount == 1 {
                    cell?.clickCount = 0
                    self?.viewModel.deleteName(model.name)
                } else {
                    cell?.clickCount += 1
                    self?.viewModel.addName(model.name)
                }
            }
            .disposed(by: disposeBag)
    
        
// - point button bind
        output.pointButtonValid
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                if b {
                    self?.roomTopView.pointerButton.isEnabled = true
                    self?.roomTopView.pointerButton.setImage(UIImage(named: "select_point"), for: .normal)
                } else {
                    self?.roomTopView.pointerButton.isEnabled = false
                    self?.roomTopView.pointerButton.setImage(UIImage(named: "unselect_point"), for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        roomTopView.pointerButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.pushViewController(ResultViewController(), animated: true)
                self.tabBarController?.tabBar.isHidden = true
            })
            .disposed(by: disposeBag)
        
        roomBottomView.inviteButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                print("invite 버튼 click")
            })
            .disposed(by: disposeBag)
    }
    
//MARK: - UIComponents

    var roomTopView = RoomTopView(frame: CGRect(x: 0, y: 0, width: Device.width, height: 500))
    
    private let peopleTableView : UITableView = {
        $0.backgroundColor = .clear
        $0.register(RoomPeopleTableViewCell.self, forCellReuseIdentifier: RoomPeopleTableViewCell.identifier)
        $0.bounces = false
        return $0
    }(UITableView())
    
    private let roomBottomView = RoomBottomView(frame: CGRect(x: 0, y: 0, width: Device.width, height: 200))
    
//MARK: - set UI
    
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
        self.title = "룸 이름"
    }
    
    func setUI() {
        view.addSubview(peopleTableView)
    }

    
    func setUIConstraints() {
        peopleTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func tableViewSetting() {
        peopleTableView.delegate = self
        peopleTableView.tableHeaderView = roomTopView
        peopleTableView.tableFooterView = roomBottomView
    }
    

//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setUIConstraints()
        tableViewSetting()
        bindViewModel()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
//        disposeBag = DisposeBag()
    }
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
}


//MARK: - TableView
extension RoomViewController : UITableViewDelegate{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
}

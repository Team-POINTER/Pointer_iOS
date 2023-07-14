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
    
//MARK: - properties
    var roomTopView = RoomTopView(frame: CGRect(x: 0, y: 0, width: Device.width, height: 500))
    
    private let peopleTableView : UITableView = {
        $0.backgroundColor = .clear
        $0.register(RoomPeopleTableViewCell.self, forCellReuseIdentifier: RoomPeopleTableViewCell.identifier)
        $0.bounces = false
        return $0
    }(UITableView())
    
    private let roomBottomView = RoomBottomView(frame: CGRect(x: 0, y: 0, width: Device.width, height: 200))
    
    let disposeBag = DisposeBag()
    let viewModel: RoomViewModel
    
    
//MARK: - Init
    init(viewModel: RoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Rx
    func bindViewModel() {
        let input = RoomViewModel.Input(hintTextEditEvent: roomTopView.hintTextField.rx.text.orEmpty.asObservable(),
                                        pointButtonTapEvent: roomTopView.pointerButton.rx.tap.asObservable(),
                                        inviteButtonTapEvent: roomBottomView.inviteButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        viewModel.roomResultObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.title = data.roomName
                self?.roomTopView.questLabel.text = data.content
            })
            .disposed(by: disposeBag)
        
// - TextField bind
        output.hintTextFieldCountString
            .bind(to: roomTopView.hintTextCount.rx.text)
            .disposed(by: disposeBag)
        
        output.hintTextFieldLimitedString
            .bind(to: roomTopView.hintTextField.rx.text)
            .disposed(by: disposeBag)
            
// - hintText bind
        output.selectedUsersJoinedString
            .bind(onNext: { [weak self] text in
                print(text)
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
        viewModel.roomResultMembersObservable
            .observe(on: MainScheduler.instance)
            .bind(to: peopleTableView.rx.items) { [weak self] tableView, index, item in
                guard let self = self,
                      let cell = tableView.dequeueReusableCell(withIdentifier: RoomPeopleTableViewCell.identifier, for: IndexPath(row: index, section: 0)) as? RoomPeopleTableViewCell
                else { return UITableViewCell() }
                cell.selectionStyle = .none
                cell.user = item
                // SelectedUser 배열 안에 있는 유저인지 확인
                // reuse 시 체크
                cell.isSelectedUser = self.viewModel.detectSelectedUser(item)
                
                /// 아래 코드는 Cell 안으로 이동 - cell.user -> didset - configure()
                /// 클래스의 단일 책임 원칙 (Cell 안에서 일어나는 일은 Cell이 책임지도록)
                return cell
            }.disposed(by: disposeBag)
        
//- tableView cell tapped
        Observable
            .zip(peopleTableView.rx.itemSelected, peopleTableView.rx.modelSelected(SearchQuestionResultMembers.self))
            .bind { [weak self] indexPath, model in
                
                // 셀 타입캐스팅, 셀 안에 있는 User 언래핑
                guard let cell = self?.peopleTableView.cellForRow(at: indexPath) as? RoomPeopleTableViewCell,
                      let user = cell.user else { return }
                
                // viewModel에 selectedUser 저장
                if cell.isSelectedUser == false {
                    self?.viewModel.selectUser(user)
                } else {
                    self?.viewModel.deSelectUser(user)
                }
                
                // cell의 isSelectedUser 토글 - 이미지 UI 전환
                cell.isSelectedUser.toggle()
                
            }
            .disposed(by: disposeBag)
    
// - point button bind
        output.pointButtonValid
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isValid in
                print("pointButton: \(isValid)")
                if isValid {
                    self?.roomTopView.pointerButton.isEnabled = true
                    self?.roomTopView.pointerButton.setImage(UIImage(named: "select_point"), for: .normal)
                } else {
                    self?.roomTopView.pointerButton.isEnabled = false
                    self?.roomTopView.pointerButton.setImage(UIImage(named: "unselect_point"), for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        output.pointButtonTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewController in
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.inviteButtonTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewController in
                print("invite 버튼 click")
            })
            .disposed(by: disposeBag)
    }
    
//MARK: - set UI
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
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
extension RoomViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

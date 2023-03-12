
//
//  RoomViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/12.
//

import UIKit
import SnapKit
import RxSwift

//MARK: 비동기로 처리해야할 부분
// 1. hint 입력했을 시 글자수 20자 제한 [X]
// 2. 테이블 뷰에서 셀들 선택 후 point 하는 부분 [X]
// 3. 링크로 초대하기 부분 [X]

//MARK: 처리해야할 부분
// 1. 테이블 뷰 더미데이터 만들기 [X] -> API 연동 [X]
// 2. 룸에서 Point를 누른 사람들을 selectPeople에 담아서 줄바꿈하여 출력[X]
// 3. 글씨체 적용 [X]
// 4. Point 버튼 이미지로 처리하는지, Font 저장 후 처리하는지 [X]
// 5. navigationBar titleColor, LeftBarItem 추가 [X]


class RoomViewController: BaseViewController {

//MARK: - Properties
    var disposeBag = DisposeBag()
    
//MARK: - UIComponents
    lazy var scrollView = UIScrollView()
    
    lazy var hintAlertLabel : UILabel = {
        $0.text = "투표한 상대에게 보여지는 당신의 힌트를 작성해주세요."
        $0.font = UIFont(name: "NotoSansKR-Regular", size: 8)
        $0.textColor = UIColor.rgb(red: 146, green: 146, blue: 146)
        $0.textAlignment = .center
        return $0
    }(UILabel())
        

    lazy var hintView : UIView = {
        $0.backgroundColor = UIColor.rgb(red: 105, green: 105, blue: 105)
        $0.layer.cornerRadius = 10
        return $0
    }(UIView())
    
    lazy var hintTextField : UITextField = {
        $0.attributedPlaceholder = NSAttributedString(
            string: "입력하세요.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 197, green: 197, blue: 197)])
        $0.font = UIFont(name: "NotoSansKR-Light", size: 15)
        $0.backgroundColor = UIColor.clear
        $0.textColor = UIColor.white
        return $0
    }(UITextField())
    
    lazy var hintTextCount : UILabel = {
        $0.text = "20/20"
        $0.font = UIFont(name: "NotoSansKR-Regular", size: 13)
        $0.textColor = UIColor.rgb(red: 151, green: 151, blue: 151)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var questLabel : UILabel = {
        $0.text = "한 20년 뒤 미래에 가장 돈을 잘 벌 것 같은 사람은 누구인가?최대 공백포함45"
        $0.font = UIFont(name: "NotoSansKR-Bold", size: 20)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var selectPeople : UILabel = {
        $0.text = "선택하지 않았어요"
//        $0.text = "Annette Black · Arlene McCoy /n Ronald Richards · Bessie Cooper /n Annette Black · Arlene McCoy /n"
        $0.font = UIFont(name: "NotoSansKR-Bold", size: 18)
        $0.textColor = UIColor.rgb(red: 96, green: 95, blue: 95)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var pointerButton : UIButton = {
        $0.backgroundColor = UIColor.pointerRed.withAlphaComponent(0.6)
        $0.setTitle("POINT", for: .normal)
        $0.titleLabel?.font = UIFont(name: "NotoSansKR-Bold", size: 13)
        $0.layer.cornerRadius = 18
        $0.isEnabled = false
        return $0
    }(UIButton())
    
    lazy var selectAlertLabel : UILabel = {
        $0.text = "질문에 알맞는 사람을 한 명 이상 선택해주세요!"
        $0.font = UIFont(name: "NotoSansKR-Regular", size: 12)
        $0.textColor = UIColor.rgb(red: 146, green: 146, blue: 146)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var peopleTableView : UITableView = {
        $0.register(RoomPeopleTableViewCell.self, forCellReuseIdentifier: RoomPeopleTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView())
    
    lazy var inviteButton : UIButton = {
        $0.setTitle("링크로 초대하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: "NotoSansKR-Bold", size: 16)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 18
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        return $0
    }(UIButton())
    
//MARK: - set UI
    
    func configureBar() {
        var image = UIImage(named: "backbtn")?.resize(newWidth: 150)
        image = image?.withRenderingMode(.alwaysOriginal) //색깔 원래대로
        let backBtn = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    func setUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(hintAlertLabel)
        scrollView.addSubview(hintView)
        hintView.addSubview(hintTextField)
        hintView.addSubview(hintTextCount)
        scrollView.addSubview(questLabel)
        scrollView.addSubview(selectPeople)
        scrollView.addSubview(pointerButton)
        scrollView.addSubview(selectAlertLabel)
        scrollView.addSubview(peopleTableView)
        scrollView.addSubview(inviteButton)
    }
    
    func setUIConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        hintAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16.52)
            make.centerX.equalToSuperview()
        }
        hintView.snp.makeConstraints { make in
            make.top.equalTo(hintAlertLabel.snp.bottom).inset(-15)
            make.leading.equalToSuperview().inset(18)
            make.trailing.equalToSuperview().offset(18)
            make.width.equalTo(UIScreen.main.bounds.width - 36)
            make.height.equalTo(40)
        }
        hintTextCount.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
        }
        hintTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(12.78)
            make.width.equalTo(hintView.snp.width).inset(38)
        }
        questLabel.snp.makeConstraints { make in
            make.top.equalTo(hintView.snp.bottom).inset(-30)
            make.leading.equalToSuperview().inset(45)
            make.trailing.equalToSuperview().inset(10)
        }
        selectPeople.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(questLabel.snp.bottom).inset(-45)
        }
        pointerButton.snp.makeConstraints { make in
            make.top.equalTo(selectPeople.snp.bottom).inset(-45)
            make.centerX.equalToSuperview()
            make.width.equalTo(125)
            make.height.equalTo(40)
        }
        selectAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(pointerButton.snp.bottom).inset(-40)
            make.centerX.equalToSuperview()
        }
        peopleTableView.snp.makeConstraints { make in
            make.top.equalTo(selectAlertLabel.snp.bottom).inset(-10)
            make.leading.equalToSuperview().inset(45)
            make.trailing.equalToSuperview().inset(45)
        }
        inviteButton.snp.makeConstraints { make in
            make.top.equalTo(peopleTableView.snp.bottom).inset(-30)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "룸 이름"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        configureBar()
        setUI()
        setUIConstraints()
    }
    
    
    
    
}


//MARK: - TableView
extension RoomViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomPeopleTableViewCell.identifier, for: indexPath) as? RoomPeopleTableViewCell else { return UITableViewCell() }
        return cell
    }
    
    
}

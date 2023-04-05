//
//  NewQuestViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/04/02.
//

import UIKit
import SnapKit

class NewQuestViewController: BaseViewController {

    
//MARK: - UI Components
    
    private let questAlertLabel : UILabel = {
        $0.text = "해당 룸에 하고 싶은 질문을 작성해주세요!\n24시간마다 선착순 1명이 질문할 수 있습니다."
        $0.font = UIFont.notoSansRegular(size: 12)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var newQuestLabel: UILabel = {
        $0.text = "질문을 입력하세요."
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 20)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var newQuestButton: UIButton = {
        var attributedString = NSMutableAttributedString(string: "질문 등록하기 22:23:34")
        attributedString.addAttribute(.font, value: UIFont.notoSansBold(size: 17), range: NSRange(location: 0, length: 7))
        attributedString.addAttribute(.font, value: UIFont.notoSans(font: .notoSansKrMedium, size: 17), range: NSRange(location: 8, length: 8))
        $0.setAttributedTitle(attributedString, for: .normal)
        $0.layer.cornerRadius = 25
        $0.backgroundColor = UIColor.pointerRed
        $0.titleLabel?.textColor = UIColor.white
        return $0
    }(UIButton())
    
    let inviteButton: UIButton = {
        $0.setTitle("링크로 초대", for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 16)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 25
        $0.backgroundColor = UIColor.clear
        $0.titleLabel?.textColor = UIColor.white
        return $0
    }(UIButton())
        
//MARK: - set UI
    func setUI(){
        view.addSubview(questAlertLabel)
        view.addSubview(newQuestLabel)
        view.addSubview(newQuestButton)
        view.addSubview(inviteButton)
    }
    
    func setConstraints() {
        questAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(75)
            make.centerX.equalToSuperview()
        }
        newQuestLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().inset(45.5)
            make.trailing.equalToSuperview().inset(45.5)
        }
        newQuestButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(-30)
            make.leading.equalToSuperview().inset(18)
            make.height.equalTo(50)
            make.width.equalTo(Device.width / 2 + 10)
        }
        inviteButton.snp.makeConstraints { make in
            make.centerY.equalTo(newQuestButton.snp.centerY)
            make.trailing.equalToSuperview().inset(18)
            make.height.equalTo(50)
            make.width.equalTo(Device.width / 3)
        }
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setConstraints()
        
        
    }
    

    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
        self.title = "룸 이름"
    }
    
    @objc func backButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}

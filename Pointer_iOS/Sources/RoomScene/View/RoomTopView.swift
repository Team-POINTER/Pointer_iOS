//
//  RoomTopView.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/14.
//

import UIKit
import SnapKit

class RoomTopView: UIView {

    private let hintAlertLabel : UILabel = {
        $0.text = "투표한 상대에게 보여지는 당신의 힌트를 작성해주세요."
        $0.font = UIFont.notoSansRegular(size: 12)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.textAlignment = .center
        return $0
    }(UILabel())
        

    let hintView : UIView = {
        $0.backgroundColor = UIColor.rgb(red: 87, green: 90, blue: 107)
        $0.layer.cornerRadius = 10
        return $0
    }(UIView())
    
    let hintTextField : UITextField = {
        $0.attributedPlaceholder = NSAttributedString(
            string: "입력하세요.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 179, green: 183, blue: 205)])
        $0.font = UIFont.notoSans(font: .notoSansKrLight, size: 15)
        $0.backgroundColor = .clear
        $0.textColor = UIColor.white
        return $0
    }(UITextField())
    
    var hintTextCount : UILabel = {
        $0.text = "20/20"
        $0.font = UIFont.notoSansRegular(size: 13)
        $0.textColor = UIColor.rgb(red: 133, green: 136, blue: 157)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    let questLabel : UILabel = {
        $0.font = UIFont.notoSansBold(size: 18.5)
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    var selectPeople : UILabel = {
        $0.text = "선택하지 않았어요"
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.rgb(red: 87, green: 90, blue: 107)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    var pointerButton : UIButton = {
        $0.setImage(UIImage(named: "unselect_point"), for: .normal)
        $0.isEnabled = false
        return $0
    }(UIButton())
    
    let selectAlertLabel : UILabel = {
        $0.text = "질문에 알맞는 사람을 한 명 이상 선택해주세요!"
        $0.font = UIFont.notoSansRegular(size: 12)
        $0.textColor = UIColor.rgb(red: 121, green: 125, blue: 148)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    func setUI() {
        self.addSubview(hintAlertLabel)
        self.addSubview(hintView)
        hintView.addSubview(hintTextField)
        hintView.addSubview(hintTextCount)
        self.addSubview(questLabel)
        self.addSubview(selectPeople)
        self.addSubview(pointerButton)
        self.addSubview(selectAlertLabel)
    }
    
    func setConstraints() {
        hintAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(16.52)
            make.centerX.equalToSuperview()
        }
        hintView.snp.makeConstraints { make in
            make.top.equalTo(hintAlertLabel.snp.bottom).inset(-15)
            make.centerX.equalToSuperview()
            make.width.equalTo(Device.width - 36)
            make.height.equalTo(45)
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
            make.top.equalTo(hintView.snp.bottom).inset(-26)
            make.leading.equalToSuperview().inset(45)
            make.trailing.equalToSuperview().inset(45)
        }
        selectPeople.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(43)
            make.top.equalTo(questLabel.snp.bottom).inset(-55)
        }
        pointerButton.snp.makeConstraints { make in
            make.bottom.equalTo(selectAlertLabel.snp.top).inset(-45)
            make.centerX.equalToSuperview()
            make.width.equalTo(125)
            make.height.equalTo(40)
        }
        selectAlertLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
    }
}

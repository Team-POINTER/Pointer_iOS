//
//  ResultView.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/19.
//

import UIKit
import SnapKit

class ResultView: UIView {
    
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
    
    let koKButton : UIButton = {
        $0.setTitle("지목하지 않은 사람에게 콕!", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 16)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 22
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        return $0
    }(UIButton())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setUI() {
        self.addSubview(hintText)
        self.addSubview(selectedPeopleLabel)
        self.addSubview(selectedPointLabel)
        self.addSubview(myNameLabel)
        self.addSubview(mySelectedPointLabel)
        self.addSubview(myResultButton)
        self.addSubview(newQuestionTimerLabel)
        self.addSubview(newQuestionButton)
        self.addSubview(koKButton)
    }
    
    func setConstraints() {
        hintText.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(37)
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
        koKButton.snp.makeConstraints { make in
            make.top.equalTo(myResultButton.snp.bottom).inset(-20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(34.5)
            make.height.equalTo(50)
        }

    }
}

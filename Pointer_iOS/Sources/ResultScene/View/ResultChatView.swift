//
//  ResultChatView.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/19.
//

import UIKit
import SnapKit

class ResultChatView: UIView{
    
    let view: UIView = {
        $0.backgroundColor = UIColor.rgb(red: 102, green: 102, blue: 102)
        $0.layer.cornerRadius = 18
        return $0
    }(UIView())
    
    let chatLabel: UILabel = {
        $0.text = "채팅"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.textColor = UIColor.pointerGray
        return $0
    }(UILabel())
    
    var chatCountLabel: UILabel = {
        $0.text = "7"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 16)
        $0.textColor = UIColor.tabbarGray
        return $0
    }(UILabel())
    
    let lineView: UIView = {
        $0.backgroundColor = .tabbarGray
        return $0
    }(UIView())
    
    let redRoundView: UIView = {
        $0.backgroundColor = .pointerRed
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        return $0
    }(UIView())
    
    var messageCount: UILabel = {
        $0.text = "22"
        $0.font = UIFont.notoSans(font: .notoSansKrBold, size: 15)
        $0.textColor = UIColor.white
        return $0
    }(UILabel())
    
    let textFieldView: UIView = {
        $0.backgroundColor = UIColor.rgb(red: 239, green: 239, blue: 239)
        $0.layer.cornerRadius = 20
        return $0
    }(UIView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setUI() {
        self.addSubview(view)
        view.addSubview(chatLabel)
        view.addSubview(chatCountLabel)
        view.addSubview(redRoundView)
        redRoundView.addSubview(messageCount)
        view.addSubview(lineView)
        view.addSubview(textFieldView)
    }
    
    func setConstraints() {
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chatLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(14)
        }
        chatCountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalTo(chatLabel.snp.trailing).inset(-4)
        }
        redRoundView.snp.makeConstraints { make in
            make.centerY.equalTo(chatLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(30)
        }
        messageCount.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.top.equalTo(chatLabel.snp.bottom).inset(-14)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(0.2)
        }
        textFieldView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(22)
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width - 50)
            make.height.equalTo(36)
        }
    }
    
}

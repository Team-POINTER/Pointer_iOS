//
//  RoomPeopleTableViewCell.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/12.
//

import UIKit
import SnapKit

class RoomPeopleTableViewCell: UITableViewCell {
    
    static let identifier = "RoomPeopleTableViewCell"

    lazy var roundView : UIView = {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 18
        return $0
    }(UIView())
    
    lazy var nameLabel : UILabel = {
        $0.text = "박현준(devjoonn)"
        $0.font = UIFont(name: "NotoSansKR-Bold", size: 16)
        $0.textColor = UIColor.rgb(red: 146, green: 146, blue: 146)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var pointkButton : UIButton = {
        $0.setImage(UIImage(named: "point"), for: .selected) // 버튼 이미지 변경해야함
        return $0
    }(UIButton())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUIandConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setUIandConstraints() {
        contentView.addSubview(roundView)
        roundView.addSubview(nameLabel)
        roundView.addSubview(pointkButton)
        
        roundView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width - 90)
            make.height.equalTo(45)
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(15)
        }
        
        pointkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(-15)
            make.width.height.equalTo(23)
        }
    }
}

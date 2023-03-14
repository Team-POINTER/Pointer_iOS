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
        $0.font = UIFont.notoSansBold(size: 16)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var pointStarButton : UIButton = {
        $0.setImage(UIImage(named: "pointer_star"), for: .selected) // 버튼 이미지 변경해야함
        return $0
    }(UIButton())
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        clipsToBounds = false
        setUIandConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setUIandConstraints() {
        contentView.addSubview(roundView)
        roundView.addSubview(nameLabel)
        roundView.addSubview(pointStarButton)
        
        roundView.snp.makeConstraints { make in
            make.leading.equalTo(42)
            make.trailing.equalTo(-42)
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(15)
        }
        
        pointStarButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(-15)
            make.width.height.equalTo(23)
        }
    }
}

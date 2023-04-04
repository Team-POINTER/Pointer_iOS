//
//  MyResultTableViewCell.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/25.
//

import UIKit
import SnapKit

class MyResultTableViewCell: UITableViewCell {
    
    static let identifier = "MyResultTableViewCell"
    
    private let view: UIView = {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = false
        return $0
    }(UIView())
    
    var hintLabel: UILabel = {
        $0.text = "가장 친해지고 싶은 사람은?"
        $0.font = UIFont.notoSans(font: .notoSansKrMedium, size: 18)
        $0.textColor = UIColor.black
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var selectedMeNumber: UILabel = {
        $0.text = "3 / 20"
        $0.font = UIFont.notoSansBold(size: 18)
        $0.textColor = UIColor.pointerRed
        return $0
    }(UILabel())
    
    var hintDate: UILabel = {
        $0.text = "23.03.25"
        $0.font = UIFont.notoSansRegular(size: 13)
        $0.textColor = UIColor.black
        return $0
    }(UILabel())
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setUIandConstraints()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 7.5, left: 0, bottom: 7.5, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    func setUIandConstraints() {
        contentView.addSubview(view)
        view.addSubview(hintLabel)
        view.addSubview(selectedMeNumber)
        view.addSubview(hintDate)
        
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hintLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(21)
            make.leading.trailing.equalToSuperview().inset(25)
        }
        selectedMeNumber.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().inset(20)
        }
        hintDate.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(15)
        }
    }

}
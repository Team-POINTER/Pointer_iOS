//
//  FloatChatTableViewCell.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/22.
//

import UIKit

//MARK: - Room 채팅 테이블 뷰 셀
class FloatingChatTableViewCell: UITableViewCell {

    static let identifier = "FloatChatTableViewCell"
    
    
    
    
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
        
    }
}

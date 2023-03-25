//
//  FloatChatTableViewCell.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/22.
//

import UIKit

class FloatChatTableViewCell: UITableViewCell {

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

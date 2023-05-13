//
//  FriendsListCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/13.
//

import UIKit

class FriendsListCell: UICollectionViewCell {
    //MARK: - Properties
    static let cellIdentifier = "FriendsListCell"

    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

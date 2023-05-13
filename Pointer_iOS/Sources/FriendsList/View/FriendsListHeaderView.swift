//
//  FriendsListHeaderView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/14.
//

import UIKit

class FriendsListHeaderView: UICollectionReusableView {
    static let headerIdentifier = "FriendsListHeaderView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

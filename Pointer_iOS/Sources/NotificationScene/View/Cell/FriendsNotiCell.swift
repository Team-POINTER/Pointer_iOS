//
//  FriendsNotiCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/26.
//

import UIKit

class FriendsNotiCell: UICollectionViewCell {
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

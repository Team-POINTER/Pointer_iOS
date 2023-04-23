//
//  PreferenceItemCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit

class PreferenceItemCell: UICollectionViewCell {
    //MARK: - Properties
    var item: PreferenceModel?
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        let color: [UIColor] = [.red, .blue, .gray, .green, .systemIndigo]
        backgroundColor = color.randomElement()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Functions
    
}

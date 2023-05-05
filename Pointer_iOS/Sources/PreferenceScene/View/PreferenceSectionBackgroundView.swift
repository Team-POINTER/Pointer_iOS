//
//  PreferenceSectionBackgroundView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit

class PreferenceSectionBackgroundView: UICollectionReusableView {
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Functions
    func setupUI() {
        // 배경색 및 테두리를 적용합니다.
        layer.cornerRadius = 30
        clipsToBounds = true
        layer.borderColor = UIColor.rgb(red: 179, green: 183, blue: 205).cgColor
        layer.borderWidth = 1.0
    }
}

//
//  PreferenceItemCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit
import SnapKit

class PreferenceItemCell: UICollectionViewCell {
    //MARK: - Properties
    var item: PreferenceModel? {
        didSet {
            configure()
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansRegular(size: 16)
        label.textColor = .white
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
//        let color: [UIColor] = [.red, .blue, .gray, .green, .systemIndigo]
//        backgroundColor = color.randomElement()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Functions
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(22)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configure() {
        guard let item = item else { return }
        titleLabel.text = item.rawValue
    }
}

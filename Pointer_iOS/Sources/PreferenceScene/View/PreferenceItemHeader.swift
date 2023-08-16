//
//  PreferenceItemHeader.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit
import SnapKit

class PreferenceItemHeader: UICollectionReusableView {
    //MARK: - Properties
    var headerType: PreferenceSectionType? {
        didSet {
            configure()
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansBold(size: 16)
        label.textColor = .white
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
//        backgroundColor = .brown
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - functions
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(22)
        }
    }
    
    private func configure() {
        guard let type = headerType else { return }
        titleLabel.text = type.title
    }
}

//
//  AllNotiCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/26.
//

import UIKit
import SnapKit

class RoomNotiCell: UICollectionViewCell {
    //MARK: - Properties
    var item: RoomAlarmList? {
        didSet {
            configure()
        }
    }
    
    let userProfilImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "defaultProfile")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "주민서님이 당신을 콕! 찔렀어요."
        label.font = .notoSans(font: .notoSansKrMedium, size: 13)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "얼른 질문을 확인하고 지목해봐요."
        label.font = .notoSansRegular(size: 11)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "3/14 11:14"
        label.font = .notoSansRegular(size: 11)
        label.textColor = .darkGray
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(userProfilImageView)
        userProfilImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
            userProfilImageView.layer.cornerRadius = 22
            userProfilImageView.clipsToBounds = true
        }
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel, dateLabel])
        stack.axis = .vertical
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.equalTo(userProfilImageView.snp.trailing).inset(-18)
            $0.trailing.equalToSuperview().inset(18)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configure() {
        guard let item = item else { return }
        titleLabel.text = item.content
        
    }
}

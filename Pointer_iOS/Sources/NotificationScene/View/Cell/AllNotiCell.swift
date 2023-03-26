//
//  AllNotiCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/26.
//

import UIKit
import SnapKit

class AllNotiCell: UICollectionViewCell {
    //MARK: - Properties
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
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "얼른 질문을 확인하고 지목해봐요."
        label.font = .notoSansRegular(size: 11)
        label.textColor = .white
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
            $0.top.equalToSuperview().inset(5)
            $0.width.height.equalTo(44)
            userProfilImageView.layer.cornerRadius = 22
            userProfilImageView.clipsToBounds = true
        }
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stack.axis = .vertical
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.equalTo(userProfilImageView.snp.trailing).inset(-18)
            $0.top.equalToSuperview().inset(8)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(stack.snp.leading)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
}

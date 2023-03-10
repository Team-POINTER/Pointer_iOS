//
//  RoomPreviewCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/11.
//

import UIKit
import SnapKit

class RoomPreviewCell: UICollectionViewCell {
    //MARK: - Properties
    let roomNameLabel: UILabel = {
        let label = UILabel()
        label.text = "우리 반"
        label.font = .notoSansRegular(size: 16)
        label.textColor = .rgb(red: 102, green: 102, blue: 102)
        return label
    }()
    
    let roomBodyLabel: UILabel = {
        let label = UILabel()
        label.text = "첫 인상이 가장 좋은 사람"
        label.font = .notoSansBold(size: 18)
        label.textColor = .black
        return label
    }()
    
    let memberCountLabel: UILabel = {
        let label = UILabel()
        label.text = "5 명"
        label.font = .notoSansRegular(size: 13)
        label.textColor = .pointerRed
        return label
    }()
    
    let starIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "pointer_star")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let leaderNameLabel: UILabel = {
        let label = UILabel()
        label.text = "포인터 님"
        label.font = .notoSansRegular(size: 13)
        label.textColor = .black
        return label
    }()

    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = false
        
        addSubview(roomNameLabel)
        addSubview(roomBodyLabel)
        addSubview(memberCountLabel)
        addSubview(starIcon)
        addSubview(leaderNameLabel)
        
        roomNameLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(21.5)
            $0.height.equalTo(27)
        }
        roomBodyLabel.snp.makeConstraints {
            $0.top.equalTo(roomNameLabel.snp.bottom)
            $0.leading.equalTo(roomNameLabel.snp.leading)
        }
        memberCountLabel.snp.makeConstraints {
            $0.leading.equalTo(roomBodyLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(21.5)
            $0.width.greaterThanOrEqualTo(23)
        }
        starIcon.snp.makeConstraints {
            $0.leading.equalTo(memberCountLabel.snp.trailing).inset(-10)
            $0.top.equalTo(memberCountLabel)
            $0.bottom.equalTo(memberCountLabel)
        }
        
        leaderNameLabel.snp.makeConstraints {
            $0.leading.equalTo(starIcon.snp.trailing).inset(-3)
            $0.top.equalTo(starIcon)
            $0.bottom.equalTo(starIcon)
        }
    }
}

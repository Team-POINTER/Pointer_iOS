//
//  AllNotiCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/26.
//

import UIKit
import Kingfisher
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
        label.text = "-"
        label.font = .notoSans(font: .notoSansKrMedium, size: 13)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    let subTitleLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.text = "-"
        label.font = .notoSansRegular(size: 11)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    lazy var subTitleContainerView: UIView = {
        let view = UIView()
        view.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.greaterThanOrEqualToSuperview()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = .notoSansRegular(size: 11)
        label.textColor = UIColor(red: 0.7, green: 0.716, blue: 0.804, alpha: 1)
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
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.height.equalTo(44)
            userProfilImageView.layer.cornerRadius = 22
            userProfilImageView.clipsToBounds = true
        }
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subTitleContainerView, dateLabel])
        stack.axis = .vertical
        stack.spacing = 1.5
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(userProfilImageView.snp.trailing).inset(-18)
            $0.trailing.equalToSuperview().inset(18)
        }
    }
    
    private func configure() {
        guard let item = item else { return }
        
        let pushType = PushType(rawValue: item.type) ?? .none
        
        titleLabel.text = pushType.generateTitle(targetUser: item.sendUserName)
        subTitleLabel.text = item.content
        
        userProfilImageView.kf.indicatorType = .activity
        userProfilImageView.kf.setImage(with: URL(string: item.sendUserProfile ?? ""))
        
        dateLabel.text = convertDateString(item.createdAt)
    }
    
    private func convertDateString(_ original: String) -> String? {
        // 원본 날짜 문자열의 형식을 정의하는 DateFormatter
        let originalFormatter = DateFormatter()
        originalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        originalFormatter.locale = Locale(identifier: "en_US_POSIX")

        // 원본 날짜 문자열을 Date 객체로 변환
        guard let date = originalFormatter.date(from: original) else {
            return nil
        }

        // Date 객체를 원하는 형식의 문자열로 변환하는 DateFormatter
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "yy.MM.dd HH:mm"

        return newFormatter.string(from: date)
    }
}

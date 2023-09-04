//
//  PreferenceItemCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import UIKit
import SnapKit

protocol PreferenceItemDelegate: AnyObject {
    func pushToggleTapped(item: PreferenceModel, value: Bool)
}

class PreferenceItemCell: UICollectionViewCell {
    //MARK: - Properties
    weak var delegate: PreferenceItemDelegate?
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
    
    var toggleView: PointerToggleView?
    
    var subTitle: UILabel = {
        let label = UILabel()
        label.font = .notoSansRegular(size: 16)
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
    
    
    //MARK: - Functions
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(22)
            $0.centerY.equalToSuperview()
        }
        
        addSubview(subTitle)
        subTitle.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(22)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configure() {
        guard let item = item else { return }
        
        if let subtitle = item.menu.subTitle {
            self.subTitle.text = subtitle
        } else {
            self.subTitle.text = ""
        }
        
        // 토글을 사용하는 item 이라면 toggle 생성
        if item.menu.toggleIsAvailable == true {
            // 토글이 있다면 이미지만 바꿔주기
            if let toggle = self.toggleView {
                toggle.setValue(item.isToggleEnabled)
            } else {
                // 토글이 없다면 생성
                let toggleView = PointerToggleView()
                toggleView.delegate = self
                // 토글 상태 넣기
                toggleView.setValue(item.isToggleEnabled)
                addSubview(toggleView)
                toggleView.snp.makeConstraints {
                    $0.trailing.equalToSuperview().inset(22)
                    $0.centerY.equalToSuperview()
                    $0.width.equalTo(50)
                    $0.height.equalTo(titleLabel.snp.height)
                }
                self.toggleView = toggleView
            }
        } else {
            // 토글을 하지 않는 item 이라면 toggle 지우기
            if let toggleView = self.toggleView {
                toggleView.removeFromSuperview()
            }
            self.toggleView = nil
        }
        
        titleLabel.text = item.menu.title
    }
}

// 토글 탭 이벤트 Delegate 수신
extension PreferenceItemCell: PointerToggleDelegate {
    func toggleValueDidChanged(value: Bool) {
        guard let item = item else { return }
        delegate?.pushToggleTapped(item: item, value: value)
    }
}

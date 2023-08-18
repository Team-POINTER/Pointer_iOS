//
//  FriendListEmptyView.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/18.
//

import UIKit

class FriendListEmptyView: UIView {
    //MARK: - Properties
    public var titleText = ""
    public var buttonText = ""
    public var buttonAction: (() -> ())?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansRegular(size: 12)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.7, green: 0.716, blue: 0.804, alpha: 1)
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.isEnabled = true
        return button
    }()
    
    //MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    //MARK: - Methods
    private func setupUI() {
        
        self.isHidden = true
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(25)
        }
        
        titleLabel.text = titleText
        
        // 버튼 텍스트가 들어왔다면 아래 함수 호출
        guard buttonText != "" else { return }
        
        self.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).inset(-5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
            $0.width.equalTo(130)
        }
        
        actionButton.layer.cornerRadius = 30 / 2
        actionButton.clipsToBounds = true
        
        let attributeString = NSAttributedString(string: buttonText, attributes: [.font: UIFont.notoSans(font: .notoSansKrMedium, size: 13), .foregroundColor: UIColor.black])
        actionButton.setAttributedTitle(attributeString, for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    @objc private func actionButtonTapped() {
        self.buttonAction?()
    }
}

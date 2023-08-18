//
//  ListEmptyView.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/18.
//

import UIKit

class ListEmptyView: UIView {
    //MARK: - Properties
    public var titleText = ""
    public var subtitleText = ""
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansBold(size: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.7, green: 0.716, blue: 0.804, alpha: 1)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansRegular(size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.7, green: 0.716, blue: 0.804, alpha: 1)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
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
        self.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.text = titleText
        subTitleLabel.text = subtitleText
    }
}

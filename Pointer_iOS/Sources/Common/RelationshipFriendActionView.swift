//
//  RelationshipFriendView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/17.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol RelationshipFriendActionDelegate: AnyObject {
    func showActionAlert(alert: PointerAlert)
    func didFriendRelationshipChanged()
}

class RelationshipFriendActionView: UIView {
    //MARK: - Properties
    weak var delegate: RelationshipFriendActionDelegate?
    let network = FriendNetworkManager()
    let relationship: Relationship
    let userId: Int
    let userStringId: String
    let userName: String
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    //MARK: - Lifecycle
    init(userId: Int, relationship: Relationship, userName: String, userStringId: String) {
        self.relationship = relationship
        self.userId = userId
        self.userStringId = userStringId
        self.userName = userName
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - Methods
    private func setupUI() {
        // 기본 액션 버튼
        let actionButton = UIButton(type: .system)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        actionButton.setAttributedTitle(relationship.smallAttributedTitle, for: .normal)
        actionButton.backgroundColor = relationship.backgroundColor
        actionButton.tintColor = relationship.tintColor
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(actionButton)
        // 요청받았다면 -> 거절 버튼 추가
        if relationship == .friendRequestReceived {
            let rejectButton = UIButton(type: .system)
            let buttonConfig = Relationship.requestRejectConfig
            rejectButton.setAttributedTitle(buttonConfig.smallAttributedTitle, for: .normal)
            rejectButton.backgroundColor = buttonConfig.backgroundColor
            rejectButton.tintColor = buttonConfig.tintColor
            rejectButton.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
            stackView.addArrangedSubview(rejectButton)
        }
        
        stackView.subviews.forEach { view in
            view.snp.makeConstraints {
                $0.width.equalTo(56)
            }
            view.layer.cornerRadius = 30 / 2
            view.clipsToBounds = true
        }
    }
    
    @objc private func actionButtonTapped() {
        // Alert 뷰 만들어서 확인
        let alert = PointerAlert.getActionAlert(
            title: relationship.alertTitle,
            message: relationship.getAlertMessage(targetName: userName,
                                                       targetId: userStringId),
            actionTitle: relationship.alertActionTitle) { [weak self] _ in
                // Alert 액션
                guard let self = self else { return }
                self.network.requestFriendAction(self.userId, router: self.relationship.router) { isSuccessed in
                    if isSuccessed {
                        self.delegate?.didFriendRelationshipChanged()
                    }
                }
            }
        
        delegate?.showActionAlert(alert: alert)
    }
    
    @objc private func rejectButtonTapped() {
        let rejectConfig = Relationship.requestRejectConfig
        let router = FriendRouter.rejectFriendRequest
        
        let alert = PointerAlert.getActionAlert(
            title: rejectConfig.alertTitle,
            message: rejectConfig.getAlertMessage(targetName: userName,
                                                       targetId: userStringId),
            actionTitle: rejectConfig.alertActionTitle) { [weak self] _ in
                // Alert 액션
                guard let self = self else { return }
                self.network.requestFriendAction(self.userId, router: router) { isSuccessed in
                    if isSuccessed {
                        self.delegate?.didFriendRelationshipChanged()
                    }
                }
            }
        
        delegate?.showActionAlert(alert: alert)
    }
}

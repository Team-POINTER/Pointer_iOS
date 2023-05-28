//
//  CustomPointerChattingListCell.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/28.
//

import UIKit
import SendbirdUIKit
import SendbirdChatSDK

class CustomPointerChattingListCell: SBUBaseChannelCell {
    // MARK: - Properties
    @SBUAutoLayout var coverImage = UIImageView()
    @SBUAutoLayout var separatorLine = UIView()
    @SBUAutoLayout var titleLabel = UILabel()
    @SBUAutoLayout var memberLabel = UILabel()
    @SBUAutoLayout var titleStackView: UIStackView = {
        let titleStackView = UIStackView()
        titleStackView.alignment = .center
        titleStackView.spacing = 4.0
        titleStackView.axis = .horizontal
        return titleStackView
    }()
    
    let kCoverImageSize: CGFloat = 40
    
    // MARK: -
    override func setupViews() {
        super.setupViews()

    }
    
    override func setupLayouts() {
        super.setupLayouts()

    }
    
    override func configure(channel: BaseChannel) {
        super.configure(channel: channel)

    }
}

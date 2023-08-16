//
//  RoomBottomView.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/14.
//

import UIKit
import SnapKit

class RoomBottomView: UIView {

    let inviteButton : UIButton = {
        $0.setTitle("친구 초대하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.notoSansBold(size: 16)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 18
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        return $0
    }(UIButton())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(inviteButton)
        
        inviteButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(45)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    
    
    
}

//
//  ValidateIdModel.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/26.
//

import UIKit

enum ValidateIdStyle: CaseIterable {
    case none
    case check
    case unformed
    case duplicated
    case avaliable
    
    var description: String {
        switch self {
        case .none: return ""
        case .check: return "중복 확인해주세요."
        case .unformed: return "형식에 어긋난 아이디입니다."
        case .duplicated: return "중복되는 ID가 있습니다."
        case .avaliable: return "사용 가능한 ID 입니다."
        }
    }
    
    var fontColor: UIColor {
        switch self {
        case .none:
            return UIColor.clear
        case .check:
            return UIColor.inactiveGray
        case .unformed:
            return UIColor.pointerRed
        case .duplicated:
            return UIColor.pointerRed
        case .avaliable:
            return UIColor.green
        }
    }
}

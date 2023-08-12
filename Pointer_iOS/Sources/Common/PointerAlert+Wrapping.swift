//
//  PointerAlert+Wrapping.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/12.
//

import Foundation

extension PointerAlert {
    static func getSimpleAlert(title: String, message: String) -> PointerAlert {
        let confirmConfig = PointerAlertActionConfig(title: "확인", textColor: .black, handler: nil)
        let alert = PointerAlert(alertType: .alert, configs: [confirmConfig], title: title, description: message)
        return alert
    }
    
    static func getActionAlert(title: String, message: String, actionTitle: String = "확인", handler: @escaping ((String?)) -> Void) -> PointerAlert {
        let cancelConfig = PointerAlertActionConfig(title: "취소", textColor: .alertGray, handler: nil)
        let confirmConfig = PointerAlertActionConfig(title: actionTitle, textColor: .pointerRed, font: .notoSans(font: .notoSansKrMedium, size: 18), handler: handler)
        let alert = PointerAlert(alertType: .alert, configs: [cancelConfig, confirmConfig], title: title, description: message)
        return alert
    }
}

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
}

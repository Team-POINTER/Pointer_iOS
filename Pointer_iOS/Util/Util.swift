//
//  Util.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/19.
//
import UIKit
import Toast

struct Util {
    static var appVersion: String? {
        if let info = Bundle.main.infoDictionary {
            let currentVersion = info["CFBundleShortVersionString"] as? String
            return currentVersion
        } else {
            return nil
        }
    }
    
    /// 토스트 메시지
    static func showToast(_ message: String, position: ToastPosition = .center, isClearToastQueue: Bool = true, duration: TimeInterval = 2) {
        ToastManager.shared.isQueueEnabled = true
        ToastManager.shared.duration = duration
        ToastManager.shared.position = position

        DispatchQueue.main.async {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            if isClearToastQueue {
                window?.clearToastQueue()
            }
            var style = ToastStyle()
            style.messageAlignment = .center
            style.cornerRadius = 10.0
            style.messageFont = UIFont.notoSansRegular(size: 13)
            style.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            window?.makeToast(message, style: style)
        }
    }
}

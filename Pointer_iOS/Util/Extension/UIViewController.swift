//
//  UIViewController.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/16.
//

import UIKit

extension UIViewController {
    func presentWithNavigationPushStyle(_ viewControllerToPresent: UIViewController, completion: (() -> Void)? = nil) {
        let screenWidth = UIScreen.main.bounds.width
        viewControllerToPresent.view.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: UIScreen.main.bounds.height)

        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.addSubview(viewControllerToPresent.view)

        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(translationX: -screenWidth * 0.3, y: 0)
            viewControllerToPresent.view.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
        }, completion: { _ in
            self.view.transform = .identity
            self.present(viewControllerToPresent, animated: false, completion: completion)
        })
    }

    func dismissWithNavigationPopStyle(completion: (() -> Void)? = nil) {
        let screenWidth = UIScreen.main.bounds.width
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
        }, completion: { _ in
            self.dismiss(animated: false, completion: completion)
        })
    }
}

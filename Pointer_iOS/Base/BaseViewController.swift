//
//  BaseViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func navigationBarBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Function
    private func setupUI() {
        view.setGradient(color1: .pointerGradientStart, color2: .pointerGradientEnd)
        
        // navigation bar title color
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: UIColor.white]
        } else {
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    
    func setNavigationBarPointerBackButton() {
        let backButton = UIBarButtonItem.getPointerBackBarButton(target: self, handler: #selector(navigationBarBackButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

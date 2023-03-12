//
//  BaseViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/08.
//

import UIKit

class BaseViewController: UIViewController {
    
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    //MARK: - Function
    private func setupUI() {
        view.setGradient(color1: .pointerGradientStart, color2: .pointerGradientEnd)
    }
}

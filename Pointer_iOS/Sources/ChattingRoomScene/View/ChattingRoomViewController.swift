//
//  ChattingRoomViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/05/23.
//

import UIKit
import SnapKit

class ChattingRoomViewController: BaseViewController {

//MARK: - RX
    
    
    
//MARK: - Properties
    
    
//MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        
        
    }

    
    
    
    
    
    
//MARK: - set NavigationBar
    private func setupNavigationController() {
        
        let backImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem.getPointerBarButton(withIconimage: backImage, size: 45, target: self, handler: #selector(handleBackButtonTaped))
        self.navigationItem.leftBarButtonItem = backButton
        
        // 우측 바버튼
        let menuImage = UIImage(systemName: "line.3.horizontal")
        let searchImage = UIImage(systemName: "magnifyingglass")

        let menuButton = UIBarButtonItem.getPointerBarButton(withIconimage: menuImage, size: 45, target: self, handler: #selector(handleMenuButtonTapped))
        let searchButton = UIBarButtonItem.getPointerBarButton(withIconimage: searchImage, size: 45, target: self, handler: #selector(handleSearchButtonTapped))

        navigationItem.rightBarButtonItems = [menuButton, searchButton]
    }
    
    @objc func handleBackButtonTaped() {
        
    }
    
    @objc func handleMenuButtonTapped() {
        
    }
    
    @objc func handleSearchButtonTapped() {
        
    }
    
}

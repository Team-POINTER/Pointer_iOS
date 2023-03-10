//
//  HomeController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/10.
//

import UIKit
import DuctTape

class HomeController: BaseViewController {
    //MARK: - Properties

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        
    }
    
    //MARK: - Selector
    @objc private func handleSearchButtonTapped() {
        print(#function)
    }
    
    @objc private func handleNotiButtonTapped() {
        print(#function)
    }
    
    //MARK: - Functions
    private func setupNavigationController() {
        // 로고
        let logoImageView = UIImageView(image: UIImage(named: "pointer_logo_main"))
        logoImageView.frame = CGRect(x: 0, y: 0, width: 120, height: 70)
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        logoImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        navigationItem.leftBarButtonItem = imageItem
        
        // 우측 바버튼
        let notiImage = UIImage(systemName: "bell")
        let searchImage = UIImage(systemName: "magnifyingglass")

        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: notiImage, size: 45, target: self, handler: #selector(handleNotiButtonTapped))
        let searchButton = UIBarButtonItem.getPointerBarButton(withIconimage: searchImage, size: 45, target: self, handler: #selector(handleSearchButtonTapped))
        
        navigationItem.rightBarButtonItems = [notiButton, searchButton]
    }
}

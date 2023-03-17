//
//  SearchController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/18.
//

import UIKit

class SearchController: BaseViewController {
    //MARK: - Properties
    
    let searchBar: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .darkGray
        tf.attributedPlaceholder = NSMutableAttributedString(string: "검색어를 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.pointerGray, NSAttributedString.Key.font: UIFont.notoSansRegular(size: 13)])
        tf.textColor = .white
        tf.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tf.widthAnchor.constraint(equalToConstant: 300).isActive = true
        tf.addLeftPadding(width: 15)
        tf.layer.cornerRadius = 20
        tf.clipsToBounds = true
        return tf
    }()
    
    //MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setupNavi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Functionse
    private func setupNavi() {
        let backButtonImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButtonImage, size: 45, target: self, handler: #selector(backButtonTapped))
        let titleView = UIBarButtonItem(customView: searchBar)
        
        navigationItem.leftBarButtonItems = [backButton, titleView]
    }
}

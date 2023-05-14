//
//  FriendsListHeaderView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/14.
//

import UIKit
import SnapKit

class FriendsListHeaderView: UICollectionReusableView {
    //MARK: - Properties
    static let headerIdentifier = "FriendsListHeaderView"
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.barStyle = .default
        return search
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    func setupUI() {
        backgroundColor = .clear
        addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

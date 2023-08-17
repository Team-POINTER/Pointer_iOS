//
//  FriendsListHeaderView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/14.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class FriendsListHeaderView: UIView {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    static let headerIdentifier = "FriendsListHeaderView"
    
    lazy var searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundGray
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(18.5)
            $0.top.bottom.equalToSuperview()
        }
        return view
    }()
    
    let searchTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.placeholder = "사용자 닉네임 또는 아이디로 검색"
        tf.font = .notoSans(font: .notoSansKrMedium, size: 15)
        return tf
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
        addSubview(searchView)
        searchView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview().inset(10)
            searchView.layer.cornerRadius = 20
        }
    }
}

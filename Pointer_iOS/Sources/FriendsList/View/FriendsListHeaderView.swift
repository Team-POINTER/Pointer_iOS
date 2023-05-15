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

//MARK: - Delegate
protocol FriendsListHeaderSearchBarDelegate: AnyObject {
    func textFieldDidChange(text: String)
}

class FriendsListHeaderView: UICollectionReusableView {
    //MARK: - Properties
    var delegate: FriendsListHeaderSearchBarDelegate?
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
    
    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.font = .notoSans(font: .notoSansKrMedium, size: 15)
        return tf
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    func bind() {
        searchTextField.rx.text
            .asObservable()
            .subscribe { [weak self] event in
                if let element = event.element,
                   let text = element,
                   let self = self {
                    self.delegate?.textFieldDidChange(text: text)
                }
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Functions
    func setupUI() {
        backgroundColor = .clear
        addSubview(searchView)
        searchView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview()
            searchView.layer.cornerRadius = 20
        }
    }
}

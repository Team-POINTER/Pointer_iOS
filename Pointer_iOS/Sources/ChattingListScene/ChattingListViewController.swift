//
//  ChattingListViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/05/28.
//

import UIKit
import RxCocoa
import RxSwift
import SendbirdUIKit
import SendbirdChatSDK

class ChattingListViewController: SBUGroupChannelListViewController {
    //MARK: - Properties
    let disposeBag = DisposeBag()
    lazy var plusButton = getPointerNavigationItem(image: UIImage(systemName: "plus"))
    
    lazy var searchButton = getPointerNavigationItem(image: UIImage(systemName: "magnifyingglass"))
    
    //MARK: - Lifecycle
    override init() {
        super.init()
//        listComponent?.register(channelCell: CustomPointerChattingListCell())

        setupUI()
        setupNavigationBar()
        bind()
    }
    
    @objc @MainActor required init(channelListQuery: GroupChannelListQuery? = nil) {
        fatalError("init(channelListQuery:) has not been implemented")
    }
    
    
    
    //MARK: - Selector
    @objc func backButtonTapped() {
        
    }
    
    //MARK: - Bind
    private func bind() {
        plusButton.rx.tap
            .subscribe { _ in
                print("DEBUG: PlusButtonTapped")
            }
            .disposed(by: disposeBag)
        searchButton.rx.tap
            .subscribe { _ in
                print("DEBUG: SearchButtonTapped")
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Functions
    func setupUI() {
        theme = .dark
    }
    
    func setupNavigationBar() {
        headerComponent?.titleView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "채팅"
        titleLabel.font = .notoSansBold(size: 18)
        titleLabel.textColor = .rgb(red: 206, green: 208, blue: 224)
        let chattingTitle = UIBarButtonItem(customView: titleLabel)
        
        headerComponent?.leftBarButton = chattingTitle
        
        let rightButtonStack = UIStackView(arrangedSubviews: [plusButton, searchButton])
        rightButtonStack.spacing = 10
        
        let rightBarButton = UIBarButtonItem(customView: rightButtonStack)
        
        headerComponent?.rightBarButton = rightBarButton
    }
    
    
    func getPointerNavigationItem(image: UIImage?) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.backgroundColor = .backgroundGray
        button.contentMode = .scaleAspectFill
        button.snp.makeConstraints {
            $0.width.height.equalTo(Device.navigationBarHeight - 15)
            button.layer.cornerRadius = (Device.navigationBarHeight - 15) / 2
            button.clipsToBounds = true
        }
        return button
    }
}

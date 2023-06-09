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
        listComponent?.register(channelCell: CustomPointerChattingListCell())

        configurationTheme()
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
    func configurationTheme() {
        SBUTheme.set(theme: .dark)
        
        SBUFontSet.h1 = .notoSans(font: .notoSansKrMedium, size: 18)
        SBUFontSet.h2 = .notoSans(font: .notoSansKrBold, size: 16)
        SBUFontSet.h3 = .notoSans(font: .notoSansKrRegular, size: 16)
        SBUFontSet.subtitle1 = .notoSans(font: .notoSansKrRegular, size: 14)
        SBUFontSet.subtitle2 = .notoSans(font: .notoSansKrMedium, size: 14)
        SBUFontSet.subtitle3 = .notoSans(font: .notoSansKrMedium, size: 14)
        SBUFontSet.body1 = .notoSans(font: .notoSansKrRegular, size: 14)
        SBUFontSet.body2 = .notoSans(font: .notoSansKrRegular, size: 14)
        SBUFontSet.body3 = .notoSans(font: .notoSansKrRegular, size: 14)
        SBUFontSet.body4 = .notoSans(font: .notoSansKrRegular, size: 14)
        SBUFontSet.button1 = .notoSans(font: .notoSansKrBold, size: 20)
        SBUFontSet.button2 = .notoSans(font: .notoSansKrMedium, size: 16)
        SBUFontSet.button3 = .notoSans(font: .notoSansKrMedium, size: 14)
        SBUFontSet.button4 = .notoSans(font: .notoSansKrMedium, size: 14)
        SBUFontSet.caption1 = .notoSans(font: .notoSansKrBold, size: 12)
        SBUFontSet.caption2 = .notoSans(font: .notoSansKrRegular, size: 12)
        SBUFontSet.caption3 = .notoSans(font: .notoSansKrRegular, size: 12)
        SBUFontSet.caption4 = .notoSans(font: .notoSansKrRegular, size: 11)
        
        SBUIconSet.iconCreate = UIImage(systemName: "plus")!
    }
    
    func setupNavigationBar() {
        headerComponent?.titleView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "채팅"
        titleLabel.font = .notoSansBold(size: 18)
        titleLabel.textColor = .rgb(red: 206, green: 208, blue: 224)
        let chattingTitle = UIBarButtonItem(customView: titleLabel)
        
        headerComponent?.leftBarButton = chattingTitle
        
        
//        let rightButtonStack = UIStackView(arrangedSubviews: [plusButton, searchButton])
//        rightButtonStack.spacing = 10
//
//        let rightBarButton = UIBarButtonItem(customView: rightButtonStack)
//
//        headerComponent?.rightBarButton = rightBarButton
    }
    
    
    func getPointerNavigationItem(image: UIImage?) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.backgroundColor = .backgroundGray
        button.contentMode = .scaleAspectFill
        button.snp.makeConstraints {
            $0.width.height.equalTo(Device.navigationBarHeight - 10)
            button.layer.cornerRadius = (Device.navigationBarHeight - 10) / 2
            button.clipsToBounds = true
        }
        return button
    }
}

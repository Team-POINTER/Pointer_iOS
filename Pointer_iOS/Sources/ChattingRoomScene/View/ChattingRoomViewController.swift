//
//  ChattingRoomViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/05/23.
//

import UIKit
import SnapKit
import SendbirdUIKit

class ChattingRoomViewController: SBUGroupChannelViewController {

//MARK: - RX
    
    
    
//MARK: - Properties
    
    
//MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setUIConstraints()
        configurationTheme()
        
    }
    
//MARK: - Custom
    func setUIConstraints() {
//        view.setGradient(color1: .pointerGradientStart, color2: .pointerGradientEnd)
    }
    
    func configurationTheme() {
        let pointerTheme = SBUTheme(
            
            groupChannelListTheme: .dark, //
            groupChannelCellTheme: .dark, // 채널에서 i 버튼 누르면
            
            channelTheme: .dark,
            
            //            channelTheme: SBUChannelTheme(
            //                statusBarStyle: .default,
            //                navigationBarTintColor: .clear,
            //                leftBarButtonTintColor: UIColor.white,
            //                rightBarButtonTintColor: UIColor.white,
            //                backgroundColor: UIColor.rgb(red: 29, green: 29, blue: 32)
            //            ),
            
            messageInputTheme: SBUMessageInputTheme(
                backgroundColor: .clear, // UIColor.pointerTextField,
                textFieldBackgroundColor: .clear, // UIColor.pointerTextField,
                textFieldPlaceholderColor: .gray,
                textFieldTextColor: .white,
                buttonTintColor: UIColor.pointerRed
            ),
            
            messageCellTheme: SBUMessageCellTheme(
                backgroundColor: .clear,
                leftBackgroundColor: UIColor.otherTextBoxColor,
                rightBackgroundColor: UIColor.myTextBoxColor,
                mentionLeftTextBackgroundColor: .black,
                mentionRightTextBackgroundColor: .white
            ),
            
            userListTheme: .dark,
            userCellTheme: .dark,
            channelSettingsTheme: .dark,
            componentTheme: .dark)
        
        SBUTheme.set(theme: pointerTheme)
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleMenuButtonTapped() {
        
    }
    
    @objc func handleSearchButtonTapped() {
        
    }
    
}

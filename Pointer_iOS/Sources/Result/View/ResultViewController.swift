//
//  ResultViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ResultViewController: BaseViewController {

    var scrollView: UIScrollView = {
        $0.bounces = false
        return $0
    }(UIScrollView())
    
    var resultView = ResultView()
    var resultChatView = ResultChatView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBar()
        setUI()
        setUIConstraints()
    }
    
    func configureBar() {
        let backButton = UIImage(systemName: "chevron.backward")
        let notiButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButton, size: 45, target: self, handler: #selector(backButtonTap))
        self.navigationItem.leftBarButtonItem = notiButton
        
        self.title = "룸 이름"
        // - navigation bar title 색상 변경
    }
    
    func setUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(resultView)
        scrollView.addSubview(resultChatView)
    }
    
    func setUIConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        resultView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }
        resultChatView.snp.makeConstraints { make in
            make.top.equalTo(resultView.koKButton.snp.bottom).inset(-30)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalTo(UIScreen.main.bounds.width - 32)
            make.height.equalTo(135)
        }
    }
    
    @objc func backButtonTap() {
        
    }
    
}


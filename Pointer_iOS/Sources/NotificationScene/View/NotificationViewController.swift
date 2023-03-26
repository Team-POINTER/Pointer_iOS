//
//  NotificationViewController.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/25.
//

import UIKit
import BetterSegmentedControl
import SnapKit
import RxSwift

class NotificationViewController: BaseViewController {
    //MARK: - Properties
    var disposeBag = DisposeBag()
    
    private lazy var notiTypeSegmentControl: BetterSegmentedControl = {
        let labelSeg = LabelSegment.segments(withTitles: ["A", "B"],
                                             normalFont: .notoSans(font: .notoSansKrMedium, size: 13),
                                             normalTextColor: .pointerGray,
                                             selectedFont: .notoSans(font: .notoSansKrMedium, size: 13),
                                             selectedTextColor: .black)
        let seg = BetterSegmentedControl(frame: .zero,
                                         segments: labelSeg,
                                         options: [.cornerRadius(21), .backgroundColor(.clear), .indicatorViewBackgroundColor(.white), .indicatorViewInset(0)])
        return seg
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        setupUI()
        bind()
    }
    
    //MARK: - Bind
    private func bind() {
        notiTypeSegmentControl.rx
            .controlEvent(.valueChanged)
            .map { [weak self] in return self?.notiTypeSegmentControl.index }
            .subscribe { [weak self] event in
                if let index = event.element?.flatMap({ $0 }) {
                    print(index)
                }
            }.disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Functions
    private func setupNavi() {
        navigationItem.title = "알림"
        
        let backButtonImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem.getPointerBarButton(withIconimage: backButtonImage, size: Device.navigationBarHeight, target: self, handler: #selector(backButtonTapped))
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupUI() {
        view.addSubview(notiTypeSegmentControl)
        notiTypeSegmentControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(84)
            $0.height.equalTo(41)
        }
    }
}

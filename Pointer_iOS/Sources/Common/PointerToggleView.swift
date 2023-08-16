//
//  PointerToggleView.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/15.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol PointerToggleDelegate: AnyObject {
    func toggleValueDidChanged(value: Bool)
}

class PointerToggleView: UIView {
    //MARK: - Properties
    weak var delegate: PointerToggleDelegate?
    var toggleValue: Bool {
        didSet {
            configureToggleImage()
//            delegate?.toggleValueDidChanged(value: toggleValue)
        }
    }
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "toggle_disable")
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle
    init() {
        self.toggleValue = false
        super.init(frame: .zero)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        imageView.rx.tapGesture()
            .when(.recognized)
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] _ in
//                self?.toggleValue.toggle()
                guard let self = self else { return }
                self.delegate?.toggleValueDidChanged(value: self.toggleValue)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Public Methods
    func setValue(_ value: Bool) {
        toggleValue = value
    }
    
    //MARK: - Methods
    private func setupUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureToggleImage() {
        if toggleValue == true {
            imageView.image = UIImage(named: "toggle_enable")
        } else {
            imageView.image = UIImage(named: "toggle_disable")
        }
    }
}

//
//  PointerAlert.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/13.
//

import UIKit
import SnapKit

struct PointerAlertActionConfig {
    let title: String
    let textColor: UIColor
    var backgroundColor: UIColor = .clear
    var font: UIFont = .notoSansRegular(size: 18)
    let handler: ((String?) -> Void)?
}

class PointerAlert: UIViewController {
    enum PointerAlertType {
        case actionSheet
        case alert
    }
    
    //MARK: - Properties
    private var alertType: PointerAlertType
    private var configs: [PointerAlertActionConfig]
    private var customView: UIView?
    
    lazy var tabBarHeight = getTabBarHeight()
    
    private var backgroundBlurView = UIView()
    private var viewBlurEffect = UIVisualEffectView(effect: UIVisualEffect())
    
    /// TopStack: 상단 버튼들 Stack
    /// BottomStack: 하단 버튼들 Stack - 취소 기본 입력됨
    private lazy var topStack = makeButtonStack(addSubViews: [])
    private lazy var bottomStack = makeButtonStack(addSubViews: [])
    
    private var alertTitle: String?
    private var alertDescription: String?
    
    private var textfieldString: String?
    
    //MARK: - Lifecycle
    init(alertType: PointerAlertType, configs: [PointerAlertActionConfig], title: String? = nil, description: String? = nil, customView: UIView? = nil) {
        self.configs = configs
        self.alertType = alertType
        self.alertTitle = title
        self.alertDescription = description
        self.customView = customView
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - Selector
    @objc private func anyButtonTapped(_ handler: (() -> Void)?) {
        self.dismiss(animated: true, completion: handler)
    }
    
    //MARK: - Fuctions
    private func setupUI() {
        // 백그라운드에 블러 이펙트 추가
        view.addSubview(backgroundBlurView)
        self.backgroundBlurView.addSubview(self.viewBlurEffect)
        self.viewBlurEffect.effect = UIBlurEffect(style: .dark)
        
        self.viewBlurEffect.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backgroundBlurView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(tabBarHeight)
        }
        
        switch alertType {
        case .actionSheet:
            setupActionSheetViews()
        case .alert:
            setupAlertViews()
        }
    }
    
    //MARK: - Action Sheet Setup View
    private func setupActionSheetViews() {
        
        // 버튼 생성
        configs.enumerated().forEach {
            let button = makeInnerView(title: $1.title, font: $1.font, textColor: $1.textColor, backgroundColor: $1.backgroundColor, index: $0, height: 70, handler: $1.handler)
            self.topStack.addArrangedSubview(button)
        }
        // 취소버튼
        let cancel = makeInnerView(title: "취소", font: .notoSansRegular(size: 18), textColor: .black, backgroundColor: .clear, index: 0, height: 70) { _ in
            
        }

        bottomStack.addArrangedSubview(cancel)
        
        // TOP / BOTTOM Stack을 새로운 Stack으로 합침
        let buttonsStack = UIStackView(arrangedSubviews: [topStack, bottomStack])
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 4
        buttonsStack.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        // 버튼 스택 추가
        view.addSubview(buttonsStack)
        buttonsStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(tabBarHeight)
        }
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) {
            buttonsStack.transform = .identity
            buttonsStack.isHidden = false
        }
    }
    
    //MARK: - Alert Setup View
    private func setupAlertViews() {
        // 버튼 스택
        let actionStack = UIStackView()
        actionStack.axis = .horizontal
        actionStack.distribution = .fillEqually
        
        // 버튼 생성
        configs.enumerated().forEach {
            let button = makeInnerView(title: $1.title, font: $1.font, textColor: $1.textColor, backgroundColor: $1.backgroundColor, index: $0, height: 50, handler: $1.handler)
            actionStack.addArrangedSubview(button)
        }
        
        // 버튼 위에 Divider 추가
        let actionContainerView = UIView()
        let divider = makeDivider()
        actionContainerView.addSubview(actionStack)
        actionContainerView.addSubview(divider)
        actionStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        divider.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        // Title / Description
        let titleLabel = makeAlertContentLabel(text: alertTitle,
                                               font: .notoSansBold(size: 22))
        let descriptionLabel = makeAlertContentLabel(text: alertDescription,
                                                     font: .notoSansRegular(size: 15))
        
        // 임시 UIView Stack
        var viewStacksArray: [UIView] = []
        
        // 커스텀 뷰가 있다면 추가, 없다면 생략
        if let customView = customView {
            if let customTextfield = customView as? CustomTextfieldView {
                customTextfield.delegate = self
            }
            viewStacksArray = [titleLabel, descriptionLabel, customView, actionContainerView]
        } else {
            viewStacksArray = [titleLabel, descriptionLabel, actionContainerView]
        }
        
        // 최종 AlertStack 생성
        let alertStack = makeAlertStackView(views: viewStacksArray)
        view.addSubview(alertStack)
        alertStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    //MARK: - UIHelper
    //MARK: - Common
    private func makeButtonStack(addSubViews: [UIView]) -> UIStackView {
        let view = UIStackView(arrangedSubviews: addSubViews)
        view.backgroundColor = .pointerGray
        view.layer.cornerRadius = 25
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
        view.axis = .vertical
        return view
    }
    
    private func makeInnerView(title: String, font: UIFont, textColor: UIColor, backgroundColor: UIColor, index: Int, height: CGFloat, handler: ((String?) -> Void)?) -> UIView {
        let view = UIView()
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : textColor])
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        view.backgroundColor = backgroundColor
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        button.setBackgroundColor(.clear, for: .normal)
        button.setBackgroundColor(.gray, for: .selected)
        
        // dismiss 이후 handler
        button.addAction(for: .touchUpInside) { [weak self] _ in
            self?.dismiss(animated: true) {
                handler?(self?.textfieldString)
            }
        }
        
        // 마지막 index가 아니라면 divider 추가 (ActionSheet의 경우)
        
        if index != configs.count - 1 {
            let divider = makeDivider()
            view.addSubview(divider)
            
            switch alertType {
            case .actionSheet:
                divider.snp.makeConstraints {
                    $0.leading.trailing.bottom.equalToSuperview()
                    $0.height.equalTo(1)
                }
                
            case .alert:
                divider.snp.makeConstraints {
                    $0.top.bottom.trailing.equalToSuperview()
                    $0.width.equalTo(1)
                }
            }
        }
        
        return view
    }
    
    private func makeDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }
    
    //MARK: - Alert Views
    private func makeAlertContentLabel(text: String?, font: UIFont) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.text = text
        label.font = font
        label.textColor = .black
        return label
    }
    
    private func makeAlertStackView(views: [UIView]) -> UIStackView {
        let alertStack = UIStackView(arrangedSubviews: views)
        alertStack.backgroundColor = .pointerGray
        alertStack.axis = .vertical
        alertStack.spacing = 15
        alertStack.layer.cornerRadius = 25
        alertStack.clipsToBounds = true
        alertStack.layoutMargins = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        alertStack.isLayoutMarginsRelativeArrangement = true
        return alertStack
    }
    
    //MARK: - TabBar Height
    private func getTabBarHeight() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        guard let window = windowScenes?.windows.first(where: { $0.isKeyWindow }) else { return .zero }
        guard let tab = window.rootViewController as? BaseTabBarController else { return .zero }
        let tabBarHeight = tab.tabBar.frame.height
        return tabBarHeight
    }
}

// MARK: - Extension

extension PointerAlert: CustomTextfieldViewDelegate {
    func textDidChanged(text: String) {
        textfieldString = text
    }
}


// UIControl + Closure
extension UIControl {
    public typealias UIControlTargetClosure = (UIControl) -> ()
    
    private class UIControlClosureWrapper: NSObject {
        let closure: UIControlTargetClosure
        init(_ closure: @escaping UIControlTargetClosure) {
            self.closure = closure
        }
    }
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIControlTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIControlClosureWrapper else { return nil }
            return closureWrapper.closure
            
        } set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIControlClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
    // UIButton에 escaping closure 축
    public func addAction(for event: UIControl.Event, closure: @escaping UIControlTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIControl.closureAction), for: event)
    }
    
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(backgroundImage, for: state)
    }
}

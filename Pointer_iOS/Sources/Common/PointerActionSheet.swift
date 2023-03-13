//
//  PointerAlert.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/03/13.
//

import UIKit
import SnapKit

protocol PointerAlertDelegate: AnyObject {
    
}

struct PointerAlertConfig {
    let title: String
    let color: UIColor
    var font: UIFont = .notoSansRegular(size: 18)
    let selector: Selector
    let handler: (() -> Void)?
}

class PointerActionSheet: UIViewController {
    
    //MARK: - Properties
    private var configs: [PointerAlertConfig]
    weak var delegate: PointerAlertDelegate?
    
    private var backgroundBlurView = UIView()
    private var viewBlurEffect = UIVisualEffectView(effect: UIVisualEffect())

    /// TopStack: 상단 버튼들 Stack
    /// BottomStack: 하단 버튼들 Stack - 취소 기본 입력됨
    private lazy var topStack = makeButtonStack(addSubViews: [])
    private lazy var bottomStack = makeButtonStack(addSubViews: [])
    
    //MARK: - Lifecycle
    init(configs: [PointerAlertConfig], delegate: UIViewController?) {
        self.configs = configs
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    //MARK: - Selector
    @objc private func anyButtonTapped(_ handler: (() -> Void)?) {
        self.dismiss(animated: true, completion: handler)
    }

    //MARK: - Fuctions
    private func setupViews() {
        
        // 탭바의 높이
        let tabBarHeight = getTabBarHeight()
        
        // 버튼 생성
        configs.enumerated().forEach {
            let button = makeInnerView(title: $1.title, font: $1.font, color: $1.color, index: $0, selector: $1.selector, handler: $1.handler)
            self.topStack.addArrangedSubview(button)
        }
        // 취소버튼
        let cancel = makeInnerView(title: "취소", font: .notoSansRegular(size: 18), color: .pointerAlertFontColor, index: 0, selector: #selector(anyButtonTapped)) {}
        bottomStack.addArrangedSubview(cancel)
        
        // TOP / BOTTOM Stack을 새로운 Stack으로 합침
        let buttonsStack = UIStackView(arrangedSubviews: [topStack, bottomStack])
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 4
        buttonsStack.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
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
    
    //MARK: - UIHelper
    private func makeButtonStack(addSubViews: [UIView]) -> UIStackView {
        let view = UIStackView(arrangedSubviews: addSubViews)
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
        view.axis = .vertical
        return view
    }
    
    private func makeInnerView(title: String, font: UIFont, color: UIColor, index: Int, selector: Selector, handler: (() -> Void)?) -> UIView {
        let view = UIView()
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color])
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        button.setBackgroundColor(.clear, for: .normal)
        button.setBackgroundColor(.gray, for: .selected)
        
        // dismiss 이후 handler
        button.addAction(for: .touchUpInside) { [weak self] _ in
            self?.dismiss(animated: true, completion: handler)
        }
        
        // 마지막 index가 아니라면 divider 추가
        if index != configs.count - 1 {
            let divider = makeDivider()
            view.addSubview(divider)
            divider.snp.makeConstraints {
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(1)
            }
        }
        return view
    }
    
    private func makeDivider() -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = .pointerGray
        return view
    }
    
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
    
    // UIButton에 escaping closure 추가
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

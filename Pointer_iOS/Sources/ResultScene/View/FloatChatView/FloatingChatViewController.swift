//
//  FloatingChatViewController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/22.
//

import UIKit
import SnapKit
import FloatingPanel

protocol ScrollableViewController where Self: UIViewController {
    var scrollView: UIScrollView { get }
}

final class FloatingChatViewController: FloatingPanelController {

    init(contentViewController: ScrollableViewController) {
            super.init(delegate: nil)
            setUpView(contentViewController: contentViewController) 
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(contentViewController: ScrollableViewController) {
        // Contents
        set(contentViewController: contentViewController)
        track(scrollView: contentViewController.scrollView)
        
        // Appearance
        let appearance: SurfaceAppearance = {
            $0.cornerRadius = 16.0
            $0.backgroundColor = .white
            $0.borderColor = .clear
            $0.borderWidth = 0
            return $0
        }(SurfaceAppearance())
        
        // Surface
        surfaceView.grabberHandle.isHidden = false
        surfaceView.grabberHandle.backgroundColor = .gray
        surfaceView.grabberHandleSize = .init(width: 40, height: 4)
        surfaceView.appearance = appearance
        
        // Backdrop
        backdropView.dismissalTapGestureRecognizer.isEnabled = false
        backdropView.backgroundColor = .black // alpha 설정은 FloatingPanelBottomLayout 델리게이트에서 설정
        
        // Layout
        let layout = TouchBlockIntrinsicPanelLayout()
        self.layout = layout
        
        // delegate
        delegate = self
    }
}

extension FloatingChatViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        let loc = fpc.surfaceLocation
        let minY = fpc.surfaceLocation(for: .full).y
        let maxY = fpc.surfaceLocation(for: .tip).y
        let y = min(max(loc.y, minY), maxY)
        fpc.surfaceLocation = CGPoint(x: loc.x, y: y)
    }
    
    // 특정 속도로 아래로 당겼을때 dismiss 되도록 처리
    public func floatingPanelWillEndDragging(_ fpc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        guard velocity.y > 50 else { return }
        dismiss(animated: true)
    }
}

//MARK: -
// TouchBlockIntrinsicPanelLayout.swift
final class TouchBlockIntrinsicPanelLayout: FloatingPanelBottomLayout {
    override var initialState: FloatingPanelState { .full }
    override var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelIntrinsicLayoutAnchor(fractionalOffset: 0, referenceGuide: .safeArea)
        ]
    }

    override func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        0.5
    }
}

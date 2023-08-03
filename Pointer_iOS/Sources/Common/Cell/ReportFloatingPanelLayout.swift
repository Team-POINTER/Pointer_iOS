//
//  ReportFloatingPanelLayout.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/03.
//

import UIKit
import FloatingPanel

class ReportFloatingPanelLayout: FloatingPanelLayout {

    init() {
        // 각 상태별 높이를 지정
        fullHeight = Device.height * 0.93
        halfHeight = Device.height * 0.4
        tipHeight = 100.0

        // 초기 상태를 full로 지정
        initialState = .full

        // 지원하는 상태를 지정
        supportedStates = [.full, .half]

        // Position을 지정 (위에서 어떻게 뜰지 설정)
        position = .bottom

        // Anchors를 지정 (FloatingPanel의 상태별 앵커를 설정)
        anchors = [.full: FloatingPanelLayoutAnchor(absoluteInset: Device.height * 0.07, edge: .top, referenceGuide: .superview),
                   .half: FloatingPanelLayoutAnchor(absoluteInset: Device.height * 0.6, edge: .bottom, referenceGuide: .superview)]
    }
    
    // 각 상태별 높이를 지정
    var fullHeight: CGFloat
    var halfHeight: CGFloat
    var tipHeight: CGFloat

    // 초기 상태를 full로 지정
    var initialState: FloatingPanelState

    // 지원하는 상태를 지정
    var supportedStates: Set<FloatingPanelState>

    var position: FloatingPanel.FloatingPanelPosition
    
    var anchors: [FloatingPanel.FloatingPanelState : FloatingPanel.FloatingPanelLayoutAnchoring]

}

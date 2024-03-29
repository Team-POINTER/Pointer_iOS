//
//  FloatingPanelController.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/08/03.
//

import UIKit
import FloatingPanel

extension FloatingPanelController {
    func changePanelStyle() {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -4.0)
        shadow.opacity = 0.15
        shadow.radius = 2
        appearance.shadows = [shadow]
        appearance.cornerRadius = 15.0
        appearance.backgroundColor = .clear
        appearance.borderColor = .clear
        appearance.borderWidth = 0

        surfaceView.grabberHandle.isHidden = false
        surfaceView.appearance = appearance

    }
    
    static func getFloatingPanelViewController(delegate: UIViewController) -> FloatingPanelController {
        let controller = FloatingPanelController(delegate: delegate as? FloatingPanelControllerDelegate)
        controller.isRemovalInteractionEnabled = true
        controller.changePanelStyle()
        controller.layout = ReportFloatingPanelLayout()
        
        return controller
    }
}

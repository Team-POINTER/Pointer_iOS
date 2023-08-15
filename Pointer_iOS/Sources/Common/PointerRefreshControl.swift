//
//  PointerRefreshControl.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/15.
//

import UIKit

class PointerRefreshControl: UIRefreshControl {
    
    //MARK: - Properties
    let action: () -> Void
    weak var target: UIViewController?
    
    //MARK: - Lifecycle
    init(target: UIViewController, action: @escaping () -> Void) {
        self.action = action
        self.target = target
        super.init(frame: .zero)
        addTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Add Target
    func addTarget() {
        self.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
    }
    
    @objc func refreshAction() {
        action()
    }
}

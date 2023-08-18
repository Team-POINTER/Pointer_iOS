//
//  LaunchScreen.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/13.
//

import UIKit
import SnapKit

class LaunchScreenController: BaseViewController {
    //MARK: - Properties
    private let mainImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pointer_login")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mainImage)
        mainImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.3)
        }
    }
}

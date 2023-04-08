//
//  ProfileViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import Foundation
import RxSwift

class ProfileViewModel {
    //MARK: - Properties
    let cellItemSpacing = CGFloat(20)
    let horizonItemCount: Int = 5
    
    //MARK: - Functions
    func getCellSize() -> CGSize {
        let width = (Device.width - (cellItemSpacing * CGFloat(horizonItemCount))) / 5
        return CGSize(width: width + 5, height: width + 30)
    }
}

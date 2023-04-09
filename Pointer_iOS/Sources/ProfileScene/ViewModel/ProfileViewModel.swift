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
    let user: User
    let cellItemSpacing = CGFloat(20)
    let horizonItemCount: Int = 5
    
    //MARK: - Computed Properties
    var userIdText: String {
        return "@\(user.userID)"
    }
    
    var friendsCountText: String {
        return "친구 \(user.friendsCount)"
    }
    
    var numberOfFriendsCellCount: Int {
        return user.friendsCount
    }
    
    //MARK: - LifeCycle
    init(user: User) {
        self.user = user
    }
    
    //MARK: - Functions
    func getCellSize() -> CGSize {
        let width = (Device.width - (cellItemSpacing * CGFloat(horizonItemCount))) / 5
        return CGSize(width: width + 5, height: width + 30)
    }
}

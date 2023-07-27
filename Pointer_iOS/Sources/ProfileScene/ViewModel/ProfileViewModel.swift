//
//  ProfileViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/08.
//

import Foundation
import RxSwift
import RxRelay

class ProfileViewModel {
    //MARK: - Properties
    let profile = BehaviorRelay<ProfileModel?>(value: nil)
    let userId: Int
    let cellItemSpacing = CGFloat(20)
    let horizonItemCount: Int = 5
    let network = ProfileNetworkManager()
    
    //MARK: - Computed Properties
    var userIdText: String {
        return "@\(profile.value?.results?.userId ?? 0)"
    }
    
    var userName: String? {
        return "\(profile.value?.results?.userName ?? "오류")"
    }
    
    var friendsCountText: String {
        return "친구 5명"
    }
    
    var numberOfFriendsCellCount: Int {
        return 10
    }
    
    //MARK: - LifeCycle
    init(userId: Int) {
        self.userId = userId
    }
    
    //MARK: - Functions
    func requestUserProfile() {
        // 자기 자신이라면 내 프로필, 아니라면 상대 프로필
        if TokenManager.getIntUserId() == self.userId {
            network.getMyProfile { [weak self] profile in
                self?.profile.accept(profile)
            }
        } else {
            network.getUserProfile(userId: userId) { [weak self] profile in
                self?.profile.accept(profile)
            }
        }
    }
    
    func getCellSize() -> CGSize {
        let width = (Device.width - (cellItemSpacing * CGFloat(horizonItemCount))) / 5
        return CGSize(width: width + 5, height: width + 30)
    }
}

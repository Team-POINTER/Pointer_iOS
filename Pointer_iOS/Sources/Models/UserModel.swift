//
//  UserModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/09.
//

import Foundation

struct User {
    enum MemberType: CaseIterable {
        case myAccount
        case following
        case notFollowing
    }
     
    let memberType: MemberType
    let userName: String
    let userID: String
    let friendsCount: Int
}

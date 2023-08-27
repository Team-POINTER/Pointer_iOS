//
//  BlockFriend.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/08/27.
//

import Foundation

struct BlockedFriendResponse: Codable {
    let status: Int
    let code: String
    let message: String
    let friendInfoList: [FriendsModel]
    let name: String
    let total: Int
    let currentPage: Int
}

//
//  RoomModel.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/07/13.
//

import Foundation

// MARK: - Welcome
struct PointerHomeModel: Codable {
    let roomList: [PointerRoomModel]
}

// MARK: - RoomList
struct PointerRoomModel: Codable {
    let roomId: Int
    let roomNm: String
    let question: String
    let memberCnt: Int
}


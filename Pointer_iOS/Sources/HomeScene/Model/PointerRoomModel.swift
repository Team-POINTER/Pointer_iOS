//
//  RoomModel.swift
//  Pointer_iOS
//
//  Created by Jisu Kim on 2023/07/13.
//

import Foundation

// MARK: - Welcome
struct PointerHomeModel: Codable {
    let status: Int
    let code: String
    let message: String
    let data: PointerRoomListModel
}

struct PointerRoomListModel: Codable {
    let roomList: [PointerRoomModel]
}

// MARK: - RoomList
struct PointerRoomModel: Codable {
    let roomId: Int
    let roomNm: String
    let question: String
    let memberCnt: Int
    let topUserName: String?
}

struct RoomNameChangeInput: Codable {
    let privateRoomNm: String
    let roomId: Int
    let userId: Int
}

struct PointerDefaultResponse: Codable {
    let status: Int
    let code: String
    let message: String
}

//MARK: - CreateRoom
struct CreateRoomResponse: Codable {
    
}

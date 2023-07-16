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
// MARK: - Welcome
struct CreateRoomResponse: Codable {
    let status: Int
    let code: String
    let message: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let accessToken: String
    let refreshToken: String
    let detailResponse: DetailResponse
}

// MARK: - DetailResponse
struct DetailResponse: Codable {
    let roomId: Int
    let roomNm: String
    let memberNum: Int
    let votingNum: Int
    let questionId: Int
    let question: String
    let limitedAt: String
    let roomMembers: [RoomMember]
}

// MARK: - RoomMember
struct RoomMember: Codable {
    let userId: Int
    let id: String
    let name: String
    let privateRoomNm: String
}

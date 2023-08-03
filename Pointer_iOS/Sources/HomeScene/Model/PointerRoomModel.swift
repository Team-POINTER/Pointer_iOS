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
    let data: PointerRoomListModel?
}

struct PointerRoomListModel: Codable {
    let roomList: [PointerRoomModel]
}

// MARK: - RoomList
struct PointerRoomModel: Codable {
    let roomId: Int
    let roomNm: String
    let questionId: Int
    let question: String
    let memberCnt: Int
    let topUserName: String?
    let voted: Bool
    let limitedAt: String
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
    let status: Int
    let code: String
    let message: String
    var data: DetailData?
    
    struct DetailData: Codable {
        let detailResponse: DetailResponse
    }
    
    struct DetailResponse: Codable {
        let roomId: Int?
        let roomNm: String?
        let memberNum: Int?
        let votingNum: Int?
        let questionId: Int?
        let question: String?
        let limitedAt: String?
        let roomMembers: [RoomMember]
    }
    
    enum Status: String {
        case success = "J002" // 성공
        case userNotFound = "C001" // 회원정보 없음
        case roomCreateOverLimit = "J005" // 생성 가능 개수 초과
        case roomCreateFail = "J003" // 룸 생성 실패
        case roomNameInvalid = "J007" // 형식에 맞지 않는 룸 이름
    }
}

// MARK: - RoomMember
struct RoomMember: Codable {
    let userId: Int
    let id: String
    let name: String
    let privateRoomNm: String
}

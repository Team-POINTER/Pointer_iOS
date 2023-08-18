//
//  NotiDetailModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/16.
//

import Foundation

// MARK: - 전체 얼림
struct NotiDetailRoomResponse: Codable {
    let code, message: String
    let result: NotiDetailRoomResult
    
    // MARK: - Result
    struct NotiDetailRoomResult: Codable {
        let newAlarm, newFriendAlarm: Bool
        let newFriendAlarmCnt: Int
        let alarmList: [RoomAlarmList]
    }
}

// MARK: - AlarmList
struct RoomAlarmList: Codable {
    let alarmId: Int
    let sendUserId: Int?
    let sendUserName: String?
    let sendUserProfile: String?
    let content: String?
    let type: String
    let createdAt: String
}

// MARK: - 친구요청 알림
struct NotiDetailFriendResponse: Codable {
    let code, message: String
    let result: [FriendAlarmList]
}

// MARK: - AlarmList
struct FriendAlarmList: Codable {
    let alarmId: Int
    let userId: Int
    let sendUserId: String
    let sendUserName: String
    let sendUserProfile: String
    let relationship: Int
    let type: String
}

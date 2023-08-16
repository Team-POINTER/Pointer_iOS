//
//  NotiDetailModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/16.
//

import Foundation

// MARK: - Welcome
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
    let content: String?
    let type: String
    let sendUserId: Int?
    let sendUserName: String?
}

// MARK: - Welcome
struct NotiDetailFriendResponse: Codable {
    let code, message: String
    let result: NotiDetailFriendResult
}

// MARK: - Result
struct NotiDetailFriendResult: Codable {
    let newAlarm: Bool
    let newFriendAlarm: Bool
    let newFriendAlarmCnt: Int
    let alarmList: [FriendAlarmList]
}

// MARK: - AlarmList
struct FriendAlarmList: Codable {
    let alarmId: Int
    let sendUserId: Int
    let sendUserName: String
    let sendUserProfile: String
    let content: String
    let type: String
}

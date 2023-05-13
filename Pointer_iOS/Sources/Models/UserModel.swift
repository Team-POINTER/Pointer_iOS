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
    
    let uid = UUID().uuidString
    let memberType: MemberType
    let userName: String
    let userID: String
    let friendsCount: Int
    
    static func getDummyUsers() -> [User] {
        // 더미 유저들
        let users: [User] = [
            User(memberType: .following, userName: "김민정", userID: "kimminjung01", friendsCount: 100),
            User(memberType: .following, userName: "박민수", userID: "parkmins00", friendsCount: 120),
            User(memberType: .following, userName: "이현우", userID: "leehyunwoo03", friendsCount: 80),
            User(memberType: .following, userName: "장수현", userID: "jangsoohyun04", friendsCount: 200),
            User(memberType: .following, userName: "이민지", userID: "leeminjee05", friendsCount: 50),
            User(memberType: .following, userName: "이철수", userID: "leecheolsu06", friendsCount: 300),
            User(memberType: .following, userName: "홍수진", userID: "hongsujin07", friendsCount: 150),
            User(memberType: .following, userName: "김영호", userID: "kimyoungho08", friendsCount: 90),
            User(memberType: .following, userName: "박지우", userID: "parkjiwoo09", friendsCount: 70),
            User(memberType: .following, userName: "정예진", userID: "jungyejin10", friendsCount: 80),
            User(memberType: .following, userName: "송하늘", userID: "songhaneul11", friendsCount: 210),
            User(memberType: .following, userName: "서지민", userID: "seoijmin12", friendsCount: 50),
            User(memberType: .following, userName: "김성수", userID: "kimseongsu13", friendsCount: 170),
            User(memberType: .following, userName: "이승우", userID: "leeseungwoo14", friendsCount: 110),
            User(memberType: .following, userName: "한나영", userID: "hannahyeong15", friendsCount: 80),
            User(memberType: .following, userName: "배준호", userID: "baejunho16", friendsCount: 240),
            User(memberType: .following, userName: "손영희", userID: "sonyeonghee17", friendsCount: 60),
            User(memberType: .following, userName: "정혜진", userID: "junghyejin18", friendsCount: 150),
            User(memberType: .following, userName: "김형철", userID: "kimhyungcheol19", friendsCount: 190),
            User(memberType: .following, userName: "이소정", userID: "leesojung20", friendsCount: 80)
        ]
        return users
    }
}

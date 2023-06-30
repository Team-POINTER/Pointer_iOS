//
//  RoomAPI.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/06/24.
//

import RxSwift

protocol RoomAPI {
    func fetchRooms() -> Single<KakaoModel>
}

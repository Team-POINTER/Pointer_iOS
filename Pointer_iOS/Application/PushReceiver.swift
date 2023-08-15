//
//  PushReceiver.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/08/16.
//

import UIKit

enum PushReceiver: Int {
    case chat = 0
    case poke = 1
    case friendRequest = 2
    case friendAccept = 3
    case question = 4
    case event = 5
    case none
}

extension PushReceiver {
    func getNextViewController(id: Int? = nil) -> UIViewController? {
        switch self {
        case .poke, .question:
            guard let roomId = id else { return nil }
            let viewModel = RoomViewModel(roomId: roomId)
            let roomVc = RoomViewController(viewModel: viewModel)
            return roomVc
        case .friendRequest, .friendAccept:
            return UIViewController()
        default:
            return nil
        }
    }
}

//
//  RoomModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/15.
//

import Foundation
import RxSwift

// 안될 시 protocol로 변경
protocol RoomModel {
    var hintText: BehaviorSubject<String> { get }
    var peopleList: BehaviorSubject<[Int]> { get }
    
//    var nickname: String { get set }
//    var height: BehaviorSubject<Double> { get }
//    var weight: BehaviorSubject<Double> { get }
//    var nicknameValidationState: BehaviorSubject<SignUpValidationState> { get }
//    func validate(text: String)
//    func signUp() -> Observable<Bool>
//    func saveLoginInfo()
//    func shuffleProfileEmoji()
}

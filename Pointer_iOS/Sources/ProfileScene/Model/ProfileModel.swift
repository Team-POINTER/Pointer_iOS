//
//  ProfileModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/07/27.
//

import Foundation

// MARK: - Welcome
struct ProfileModel: Codable {
    let status: Int
    let code: String
    let message: String
    let results: ProfileResults?
}

// MARK: - Results
struct ProfileResults: Codable {
    let userId: Int
    let id: String
    let userName: String
    let point: Int
    let imageUrls: ProfileImageUrls
}

// MARK: - ImageUrls
struct ProfileImageUrls: Codable {
    let profileImageUrl: String
    let backgroundImageUrl: String
}

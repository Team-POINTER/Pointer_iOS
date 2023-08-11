//
//  ProfileNetworkManager.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/07/27.
//

import Foundation
import Alamofire
import UIKit

class ProfileNetworkManager {
    
    func getMyProfile(completion: @escaping (ProfileModel?) -> Void) {
        let router = ProfileRouter.selfProfile
        
        AF.request(router.url, method: router.method, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: ProfileModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(result)
                // 실패인 경우
                case .failure(let error):
                    print("프로필 조회 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(nil)
                }
            }
    }
    
    func getUserProfile(userId: Int, completion: @escaping (ProfileModel?) -> Void) {
        let router = ProfileRouter.userProfile(userId)
        
        AF.request(router.url, method: router.method, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: ProfileModel.self) { response in
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(result)
                // 실패인 경우
                case .failure(let error):
                    print("프로필 조회 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(nil)
                }
            }
    }
    
    func getUserFriendList(userId: Int, lastPage: Int, completion: @escaping (FriendsResponseModel?) -> Void) {
        let router = ProfileRouter.getFriendsList(userId: userId, lastPage: lastPage)
        
        AF.request(router.url, method: router.method, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: FriendsResponseModel.self) { response in
                print("url: \(router.url)")
                switch response.result {
                // 성공인 경우
                case .success(let result):
                    // completion 전송
                    completion(result)
                // 실패인 경우
                case .failure(let error):
                    print("프로필 조회 실패 - \(error.localizedDescription)")
                    // completion 전송
                    completion(nil)
                }
            }
    }
    
    // 유저 아이디 변경
    func requestChangeUserId(changeTo userID: String, completion: @escaping (Bool) -> Void) {
        let router = ProfileRouter.updateUserId
        let param: [String: String] = ["id": userID]
        
        print("🔥URL: \(router.url)")
        AF.request(router.url, method: router.method, parameters: param, encoding: JSONEncoding.default, headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointerDefaultResponse.self) { response in
                switch response.result {
                case .success(let result):
                    if result.code == "D000" {
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
    }
    
    // 프로퍼티를 받아 이미지와 JSON 데이터를 서버에 전송하는 함수
    func uploadImages(profileImage: UIImage?,
                      backgroundImage: UIImage?,
                      name: String,
                      profileImageDefaultChange: Bool,
                      backgroundImageDefaultChange: Bool,
                      completion: @escaping (Bool) -> Void) {

        let router = ProfileRouter.updateName
        var profileImageData: Data?
        var backgroundImageData: Data?
        
        // 프로필 이미지가 있다면 데이터 넣어서 변환
        if let profileImage = profileImage,
           let compressed = profileImage.jpegData(compressionQuality: 0.2) {
            profileImageData = compressed
        }
        
        // 백그라운드 이미지가 있다면 데이터 넣기
        if let backgroundImage = backgroundImage,
           let compressed = backgroundImage.jpegData(compressionQuality: 0.2) {
            backgroundImageData = compressed
        }
        
        let requestData = getModifyRequestJsonData(
            name: name,
            profileImageDefaultChange: profileImageDefaultChange,
            backgroundImageDefaultChange: backgroundImageDefaultChange)
        
        AF.upload(multipartFormData: { [weak self] multipartFormData in
            guard let self = self else { return }
            // profile이 있다면 append
            if let profile = profileImageData {
//                print("👉업로드하는 profile: \(profile)")
                multipartFormData.append(profile, withName: "profile-image", fileName: self.getImageName(type: .profile), mimeType: "image/jpeg")
            }
            
            // background가 있다면 append
            if let background = backgroundImageData {
//                print("👉업로드하는 background: \(background)")
                multipartFormData.append(background, withName: "background-image", fileName: self.getImageName(type: .background), mimeType: "image/jpeg")
            }
            
            // request가 있다면 append
            if let request = requestData {
                multipartFormData.append(request, withName: "request", mimeType: "application/json")
            }
            
        }, to: router.url, method: router.method, headers: router.headers)
        .responseDecodable(of: PointerDefaultResponse.self) { response in
            switch response.result {
            case .success(let data):
                print("🔥업로드 response: \(data)")
                if data.code == "D000" {
                    completion(true)
                } else {
                    completion(false)
                    print("🔥data: \(data)")
                }
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func getModifyRequestJsonData(name: String,
                                  profileImageDefaultChange: Bool,
                                  backgroundImageDefaultChange: Bool) -> Data? {
        
        // JSON 데이터를 생성합니다.
        let requestPayload: [String: Any] = [
            "name": name,
            "profileImageDefaultChange": profileImageDefaultChange ? "true" : "false",
            "backgroundImageDefaultChange": backgroundImageDefaultChange ? "true" : "false"
        ]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestPayload, options: [])
            return requestData
        } catch {
            return nil
        }
    }
    
    func getImageName(type: ProfileEditViewController.PhotoEditType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        let now = formatter.string(from: Date())
        let userId = TokenManager.getIntUserId()
        let type = type == .profile ? "profile" : "background"
        
        let imageName = "pointer_\(userId)_\(type)_\(now).jpeg"
        return imageName
    }
}

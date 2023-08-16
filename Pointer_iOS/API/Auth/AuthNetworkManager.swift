//
//  LoginDataManger.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/26.
//

import Foundation
import Alamofire

enum LoginResultType: String, CaseIterable {
    case success = "A000"
    case existedUser = "A001"
    case serviceAgreeUser = "C011"
    case doubleCheck = "C004"
    case duplicatedId = "A002"
    case saveId = "C003"
    case haveToCheckId = "C005"
    case notFoundId = "C001"
    case reissuedToken = "H000"
    case expiredToken = "G002"
    case unknownedError
    
    var message: String {
        switch self {
        case .success: return "회원가입 완료"
        case .existedUser: return "존재하는 유저"
        case .serviceAgreeUser: return "약관에 동의한 유저"
        case .unknownedError: return "알 수 없는 에러"
        case .doubleCheck: return "아이디 사용 가능"
        case .duplicatedId: return "중복된 아이디"
        case .saveId: return "ID 저장 성공"
        case .haveToCheckId: return "ID 중복 확인 실패"
        case .notFoundId: return "회원 정보 없음"
        case .reissuedToken: return "토큰 재발급"
        case .expiredToken: return "만료된 JWT 토큰"
        }
    }
}

class AuthNetworkManager {
    
//MARK: - shared
    static let shared = AuthNetworkManager()
    let router = AuthRouter.self
    
//MARK: - Function
    func posts(_ parameter: AuthInputModel, _ completion: @escaping (AuthResultModel, LoginResultType) -> Void){
        print("Login URL = \(AuthRouter.login.url)")
        
        AF.request(router.login.url,
                   method: router.login.method,
                   parameters: parameter,
                   encoder: JSONParameterEncoder.default,
                   headers: router.login.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthResultModel.self) { response in
            switch response.result {
                // 성공인 경우
            case .success(let result):
                print("소셜 로그인 데이터 전송 성공 - \(result)")
                // rawValue로 resultType 생성
                let loginResultType = LoginResultType(rawValue: result.code) ?? .unknownedError
                // completion 전송
                completion(result, loginResultType)
                // 실패인 경우
            case .failure(let error):
                print("소셜 로그인 데이터 전송 실패")
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
    func appleLogin(appleToken: String, completion: @escaping (AuthResultModel, LoginResultType) -> Void) {
        let router = AuthRouter.appleLogin
        let param: [String: String] = ["identityToken": appleToken]
        
        AF.request(router.url, method: router.method, parameters: param, encoding: JSONEncoding.default)
//            .response { response in
//                switch response.result {
//                case .success(let data):
//                    print("Image uploaded successfully: \(String(data: data!, encoding: .utf8) ?? "")")
//                case .failure(let error):
//                    print("Error uploading image: \(error)")
//                }
//            }
            .responseDecodable(of: AuthResultModel.self) { response in
                switch response.result {
                    // 성공인 경우
                case .success(let result):
                    print("소셜 로그인 데이터 전송 성공 - \(result)")
                    // rawValue로 resultType 생성
                    let loginResultType = LoginResultType(rawValue: result.code) ?? .unknownedError
                    // completion 전송
                    completion(result, loginResultType)
                    // 실패인 경우
                case .failure(let error):
                    print("소셜 로그인 데이터 전송 실패")
                    print(error.localizedDescription)
                    print(response.error ?? "")
                }
            }
    }
    
    func agreePost(_ parameter: AuthAgreeInputModel, _ accessToken: String, _ completion: @escaping (AuthResultModel) -> Void) {
        let router = router.agree(accessToken)
        
        AF.request(router.url,
                   method: router.method,
                   parameters: parameter,
                   encoder: JSONParameterEncoder.default,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthResultModel.self) { response in
            switch response.result {
            case .success(let result):
                print("동의 항목 전송 성공 - \(result)")
                completion(result)
            case .failure(let error):
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
    func idCheckPost(_ parameter: AuthCheckIdInputModel, _ accessToken: String,
                     _ completion: @escaping (PointerResultModel, LoginResultType) -> Void) {
        print("중복 확인 버튼 함수 시작")
        let router = router.checkId(accessToken)
        
        AF.request(router.url,
                   method: router.method,
                   parameters: parameter,
                   encoder: JSONParameterEncoder.default,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointerResultModel.self) { response in
            switch response.result {
            case .success(let result):
                print("ID 중복 확인 데이터 전송 성공 - \(result)")
                // rawValue로 resultType 생성
                let loginResultType = LoginResultType(rawValue: result.code) ?? .unknownedError
                // 핸들러로 전송
                completion(result, loginResultType)
            case .failure(let error):
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
    func idSavePost(_ parameter: AuthSaveIdInputModel, _ accessToken: String,
                    _ completion: @escaping (PointerResultModel, LoginResultType) -> Void) {
        print("확인 버튼 함수 시작")
        let router = router.saveId(accessToken)
        
        AF.request(router.url,
                   method: router.method,
                   parameters: parameter,
                   encoder: JSONParameterEncoder.default,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: PointerResultModel.self) { response in
            switch response.result {
            case .success(let result):
                print("ID 저장 데이터 전송 성공 - \(result)")
                // rawValue로 resultType 생성
                let loginResultType = LoginResultType(rawValue: result.code) ?? .unknownedError
                completion(result, loginResultType)
            case .failure(let error):
                print(error.localizedDescription)
                print(response.error ?? "")
            }
        }
    }
    
    /// 리프레시 토큰으로 액세스 토큰 재발급
    func reissuePost(_ refreshToken: String, _ completion: @escaping (Bool) -> Void) {
        let router = router.reissue(refreshToken)
        
        AF.request(router.url,
                   method: router.method,
                   headers: router.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: AuthResultModel.self) { response in
            switch response.result {
            case .success(let model):
                print("Token 재발급 데이터 전송 성공 - \(model)")
                // 재발급 성공
                if LoginResultType(rawValue: model.code) == .reissuedToken {
                    
                    // 토큰 모델 받아오기
                    guard let tokens = model.tokenDto else { return }
                    let newAccessToken = tokens.accessToken
                    let newRefeshToken = tokens.refreshToken
                    let userId = tokens.userId
                    
                    // 토큰 초기화 후 재설정
                    TokenManager.resetUserToken()
                    TokenManager.saveUserAccessToken(accessToken: newAccessToken)
                    TokenManager.saveUserRefreshToken(refreshToken: newRefeshToken)
                    TokenManager.saveUserId(userId: String(userId))
                    completion(true)
                } else {
                    // 재발급 실패
                    completion(false)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    func validateAccessToken(completion: @escaping (Bool) -> Void) {
        let router = AuthRouter.validate
        
        AF.request(router.url, method: router.method, headers: router.headers)
            .responseDecodable(of: PointerDefaultResponse.self) { [weak self] response in
                switch response.result {
                case .success(let data):
                    if data.code == "G005" {
                        completion(true)
                    } else {
                        // 오류인 경우.. refresh 도전, 언래핑 먼저
                        guard let refreshToken = TokenManager.getUserRefreshToken(), !refreshToken.isEmpty else {
                            completion(false)
                            return
                        }
                        self?.reissuePost(refreshToken, completion)
                    }
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
    }
    
}


//MARK: - 회원가입 시
struct AuthInputModel: Encodable {
    let accessToken: String
}

struct AuthResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
    let tokenDto: PointerToken?
}

struct PointerToken: Decodable {
    let userId: Int
    let accessToken: String
    let refreshToken: String
}

//MARK: - 동의 항목
struct AuthAgreeInputModel: Encodable {
    let serviceAgree: Int
    let serviceAge: Int
    let marketing: Int
}


//MARK: - ID 중복 체크, 저장 시
struct AuthSaveIdInputModel: Encodable {
    let id: String
}

struct AuthCheckIdInputModel: Encodable {
    let userId: Int
    let id: String
}

struct PointerResultModel: Decodable {
    let status: Int
    let code: String
    let message: String
}

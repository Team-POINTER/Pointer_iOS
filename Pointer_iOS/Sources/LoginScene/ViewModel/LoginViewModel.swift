
//
//  LoginViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/24.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import RxSwift
import RxCocoa

class LoginViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    init() {
        print("LoginViewModel Called")
    }
    
    struct Input {
        let kakaoLoginTap: Observable<Void>
        let appleLoginTap: Observable<Void>
    }
    
    struct Output {
        var kakaoLogin: Observable<Void>
        var appleLogin: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let kakao = input.kakaoLoginTap
        
        let apple = input.appleLoginTap
            .map(appleLoginTap)
       
        return Output(kakaoLogin: kakao, appleLogin: apple)
    }

//MARK: - APPLE
    func appleLoginTap() {
        print("애플로그인 버튼 Tap")
    }
    
    
//MARK: - KAKAO
    
    func loginWithWeb(completion: @escaping (String) -> Void) {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoAccount() success.")
                    
                    // 유저 정보
                    UserApi.shared.me() {(user, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            print("user.kakaoAccout = \(String(describing: user?.kakaoAccount))")
                            
                            // Token & User
                            guard let accessToken = oauthToken?.accessToken else { return }
                            guard let refreshToken = oauthToken?.refreshToken else {return}
                            guard let userNickname = user?.kakaoAccount?.profile?.nickname else { return }
                            print("access Token 정보입니다 !!!!!!!!!\(String(describing: accessToken))")
                            print("refresh Token 정보입니다 @@@@@@@@@@@@@@\(String(describing: refreshToken))")
                            print("Web으로 로그인")
                            print("userNickname = \(String(describing: userNickname))")
                            
                            let kakaoData = KakaoInput(accessToken: accessToken)
                            LoginDataManager.posts(kakaoData) { model, loginResultType in
                                let accessToken = model.accessToken
                                _ = TermsViewModel(loginAccessToken: accessToken)
                                if loginResultType == .success {
                                    completion(loginResultType.message)
                                } else {
                                    completion(loginResultType.message)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    
    func loginWithApp(completion: @escaping (String) -> Void) {
        
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoTalk() success.")
                
                // 유저 정보
                UserApi.shared.me() {(user, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("user.kakaoAccout = \(String(describing: user?.kakaoAccount))")
                        
                        // Token & User
                        guard let accessToken = oauthToken?.accessToken else { return }
                        guard let refreshToken = oauthToken?.refreshToken else {return}
                        guard let userNickname = user?.kakaoAccount?.profile?.nickname else { return }
                        print("access Token 정보입니다 !!!!!!!!!\(String(describing: accessToken))")
                        print("refresh Token 정보입니다 @@@@@@@@@@@@@@\(String(describing: refreshToken))")
                        print("Web으로 로그인")
                        print("userNickname = \(String(describing: userNickname))")
                        
                        let kakaoData = KakaoInput(accessToken: accessToken)
                        LoginDataManager.posts(kakaoData) { model, loginResultType in
                            let accessToken = model.accessToken
                            _ = TermsViewModel(loginAccessToken: accessToken)
                            if loginResultType == .success {
                                completion(loginResultType.message)
                            } else {
                                completion(loginResultType.message)
                            }
                        }
                    }
                }
            }
        }
    }
    
}


// 로그아웃
//    func kakaoLogOut() {
//        UserApi.shared.logout { (error) in
//            if let error = error {
//                print(error)
//            } else {
//                print("로그아웃 완료")
//            }
//        }
//    }



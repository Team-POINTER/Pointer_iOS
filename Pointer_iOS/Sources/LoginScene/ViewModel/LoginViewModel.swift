
//
//  LoginViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/24.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

class LoginViewModel {
    
    init() {
        print("LoginViewModel Called")
    }
    
    
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
                            LoginDataManager.posts(kakaoData) { model, userInfo in
                                let accessToken = model.accessToken
                                let vm = TermsViewModel()
                                vm.loginAccessToken = accessToken
                                if userInfo == "회원가입 완료" {
                                    completion("서비스이용동의 이동")
                                } else {
                                    completion("존재하는 회원")
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
                        LoginDataManager.posts(kakaoData) { model, userInfo in
                            let accessToken = model.accessToken
                            let vm = TermsViewModel()
                            vm.loginAccessToken = accessToken
                            if userInfo == "회원가입 완료" {
                                completion("서비스이용동의 이동")
                            } else {
                                completion("존재하는 회원")
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



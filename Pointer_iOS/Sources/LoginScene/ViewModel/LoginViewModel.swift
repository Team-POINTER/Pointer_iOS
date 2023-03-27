
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

    // 카카오 로그인 버튼 addTarget에 kakaoLoginButtonClicked() 추가 - []
    func kakaoInstallCheck() {
        // 카카오톡 설치 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            // 카카오톡 로그인. api 호출 결과를 클로저로 전달.
            loginWithApp()
        } else {
            // 만약, 카카오톡이 깔려있지 않을 경우에는 웹 브라우저로 카카오 로그인함.
            loginWithWeb()
        }
    }

    func loginWithWeb() {
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
                        guard let authToken = oauthToken else {return}
                        guard let accessToken = oauthToken?.accessToken else { return }
                        guard let refreshToken = oauthToken?.refreshToken else {return}
                        guard let userNickname = user?.kakaoAccount?.profile?.nickname else { return }
                        print("auth Token 전체 : \(authToken)")
                        print("access Token 정보입니다 !!!!!!!!!\(String(describing: accessToken))")
                        print("refresh Token 정보입니다 @@@@@@@@@@@@@@\(String(describing: refreshToken))")
                        print("Web으로 로그인")
                        print("userNickname = \(String(describing: userNickname))")
                        
                        let kakaoData = KakaoInput(accessToken: accessToken)
                        LoginDataManager.posts(kakaoData) { model in
                            let accessToken = model.accessToken
                            let vm = TermsViewModel()
                            vm.loginAccessToken = accessToken
                        }
                        
                        //                        let kakaoData = KakaoInput(nickname: userNickname, accessToken: accessToken)
                        //                        LoginDataManager.posts(kakaoData) { model in
                        //                            let nickname = model.nickname
                        //                            let accessToken = model.accessToken
                        //                            let vc = TermsViewController()
                        //                            vc.loginNickname = nickname
                        //                            vc.loginAccessToken = accessToken
                        //                            LoginViewController().navigationController?.pushViewController(vc, animated: true)
                        
                    }
                }
            }
        }
    }


    func loginWithApp() {
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
                        let accessToken = oauthToken?.accessToken
                        let refreshToken = oauthToken?.refreshToken
                        guard let userNickname = user?.kakaoAccount?.profile?.nickname else { return }
                        print("access Token 정보입니다 !!!!!!!!!\(String(describing: accessToken))")
                        print("refresh Token 정보입니다 @@@@@@@@@@@@@@\(String(describing: refreshToken))")
                        print("Web으로 로그인")
                        print("userNickname = \(String(describing: userNickname))")
                        
//                        let kakaoData = KakaoInput(nickname: userNickname, accessToken: accessToken ?? "")
//                        LoginDataManager.posts(kakaoData) { model in
//                            let nickname = model.nickname
//                            let accessToken = model.accessToken
//                            let vc = TermsViewController()
//                            vc.loginNickname = nickname
//                            vc.loginAccessToken = accessToken
//                            LoginViewController().navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }

//    func setUserToken() {
//        // 사용자 액세스 토큰 정보 조회
//        UserApi.shared.accessTokenInfo {(accessTokenInfo, error) in
//            if let error = error {
//                print(error)
//            }
//            else {
//                print("accessTokenInfo() success.")
//
//                //do something
//                _ = accessTokenInfo
//                print("accessToken 정보 : \(accessTokenInfo!)")
//            }
//        }
//    }

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



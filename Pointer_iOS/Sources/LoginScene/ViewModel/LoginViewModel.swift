
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
            }
            else {
                print("loginWithKakaoAccount() success.")

                //do something
                _ = oauthToken

                // 어세스토큰
                let accessToken = oauthToken?.accessToken
                print("어세스 토큰 정보입니다 !!!!!!!!!\(String(describing: accessToken))")

                //카카오 로그인을 통해 사용자 토큰을 발급 받은 후 사용자 관리 API 호출
                self.setUserInfo()

                // 뷰컨 이동 함수 추가 []
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

                //do something
                _ = oauthToken

                // 어세스토큰
                let accessToken = oauthToken?.accessToken
                print("어세스 토큰 정보입니다 @@@@@@@@@@@@@@\(String(describing: accessToken))")

                //카카오 로그인을 통해 사용자 토큰을 발급 받은 후 사용자 관리 API 호출
                self.setUserInfo()
            }
        }
    }

    func setUserInfo() {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                //do something
                _ = user
            }
        }
    }

    func setUserToken() {
        // 사용자 액세스 토큰 정보 조회
        UserApi.shared.accessTokenInfo {(accessTokenInfo, error) in
            if let error = error {
                print(error)
            }
            else {
                print("accessTokenInfo() success.")

                //do something
                _ = accessTokenInfo
                print("accessToken 정보 : \(accessTokenInfo!)")
            }
        }
    }

    // 로그아웃
    func kakaoLogOut() {
        UserApi.shared.logout { (error) in
            if let error = error {
                print(error)
            } else {
                print("로그아웃 완료")
            }
        }
    }

}


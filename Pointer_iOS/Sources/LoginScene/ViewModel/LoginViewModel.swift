
//
//  LoginViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/24.
//

import Foundation
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser
import RxSwift
import RxCocoa

class LoginViewModel: NSObject, ViewModelType {
    
    var disposeBag = DisposeBag()
    var appleLoginUser = PublishRelay<AppleUser>()
    var kakaoLoginView = PublishRelay<UIViewController>()
    
    struct Input {
        let kakaoLoginTap: Observable<Void>
        let appleLoginTap: Observable<Void>
    }
    
    struct Output {
        var kakaoLogin = PublishRelay<UIViewController>()
        var appleLogin = PublishRelay<AppleUser>()
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.kakaoLoginTap
            .subscribe(onNext: { [weak self] in
                if (UserApi.isKakaoTalkLoginAvailable()) {
                    self?.loginWithApp() { LoginResultTypeMessage in
                        if LoginResultTypeMessage == "존재하는 유저" {
                            self?.kakaoLoginView.accept(TermsViewController())
                        } else {
                            self?.kakaoLoginView.accept(BaseTabBarController())
                        }
                    }
                } else {
                    self?.loginWithWeb() { LoginResultTypeMessage in
                        if LoginResultTypeMessage == "존재하는 유저" {
                            self?.kakaoLoginView.accept(TermsViewController())
                        } else {
                            self?.kakaoLoginView.accept(BaseTabBarController())
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
        kakaoLoginView
            .subscribe(onNext: { [weak self] viewController in
                output.kakaoLogin.accept(viewController)
            })
        
        
        input.appleLoginTap
            .subscribe(onNext: { [weak self] in
                self?.appleLoginTaped()
            })
            .disposed(by: disposeBag)
        
        appleLoginUser
            .subscribe(onNext: { [weak self] user in
                output.appleLogin.accept(user)
            })
            .disposed(by: disposeBag)
        
        return output
    }

//MARK: - APPLE
    func appleLoginTaped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
//        controller.presentationContextProvider = self
        controller.performRequests()
        
        
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


extension LoginViewModel: ASAuthorizationControllerDelegate {
    // 애플 로그인 성공
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let familyName = appleIDCredential.fullName?.familyName
                let givenName = appleIDCredential.fullName?.givenName
                let email = appleIDCredential.email
                let state = appleIDCredential.state
                
                let user = AppleUser(
                    userIdentifier: userIdentifier,
                    familyName: familyName,
                    givenName: givenName,
                    email: email
                )
                
                self.appleLoginUser.accept(user)
            }
        }
        
        // 애플 로그인 실패
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print("Apple Sign In Error: \(error.localizedDescription)")
        }
}

//extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        <#code#>
//    }
//
//}

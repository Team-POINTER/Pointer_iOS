
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
    
//MARK: - Properties
    var disposeBag = DisposeBag()
    var appleLoginUser = PublishRelay<AppleUser>()
    var kakaoLoginView = PublishRelay<UIViewController>()
    
//MARK: - In/Out
    struct Input {
        let kakaoLoginTap: Observable<Void>
        let appleLoginTap: Observable<Void>
    }
    
    struct Output {
        var kakaoLogin = PublishRelay<UIViewController>()
        var appleLogin = PublishRelay<AppleUser>()
    }
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.kakaoLoginTap
            .subscribe(onNext: { [weak self] in
                if (UserApi.isKakaoTalkLoginAvailable()) {
                    self?.loginWithApp() { loginResultType, model in
                        switch loginResultType {
                        case .success:
                            self?.kakaoLoginView.accept(BaseTabBarController())
                        case .existedUser:
                            let termsViewModel = TermsViewModel(authResultModel: model)
                            self?.kakaoLoginView.accept(TermsViewController(viewModel: termsViewModel))
                        case .dataBaseError:
                            return
                        }
                    }
                } else {
                    self?.loginWithWeb() { loginResultType, model in
                        switch loginResultType {
                        case .success:
                            self?.kakaoLoginView.accept(BaseTabBarController())
                        case .existedUser:
                            let termsViewModel = TermsViewModel(authResultModel: model)
                            self?.kakaoLoginView.accept(TermsViewController(viewModel: termsViewModel))
                        case .dataBaseError:
                            return
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        kakaoLoginView
            .subscribe(onNext: { viewController in
                output.kakaoLogin.accept(viewController)
            })
            .disposed(by: disposeBag)
        
        
        input.appleLoginTap
            .subscribe(onNext: { [weak self] in
                self?.appleLoginTaped()
            })
            .disposed(by: disposeBag)
        
        appleLoginUser
            .subscribe(onNext: { user in
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
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
        
    }
    
//MARK: - KAKAO
    
    func loginWithWeb(completion: @escaping (LoginResultType, AuthResultModel) -> Void) {
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
                        // Token & User
                        guard let accessToken = oauthToken?.accessToken else { return }
                        guard let refreshToken = oauthToken?.refreshToken else {return}
                        guard let userNickname = user?.kakaoAccount?.profile?.nickname else { return }
                        print("Web으로 로그인 ")
                        
                        let kakaoData = AuthInputModel(accessToken: accessToken)
                        LoginDataManager.posts(kakaoData) { model, loginResultType in
                            completion(loginResultType, model)
                        }
                    }
                }
            }
        }
    }
    
    
    func loginWithApp(completion: @escaping (LoginResultType, AuthResultModel) -> Void) {
        
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
                        // Token & User
                        guard let accessToken = oauthToken?.accessToken else { return }
                        guard let refreshToken = oauthToken?.refreshToken else {return}
                        guard let userNickname = user?.kakaoAccount?.profile?.nickname else { return }
                        print("App으로 로그인")
                        
                        let kakaoData = AuthInputModel(accessToken: accessToken)
                        LoginDataManager.posts(kakaoData) { model, loginResultType in
                            completion(loginResultType, model)
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

//MARK: - Apple
extension LoginViewModel: ASAuthorizationControllerDelegate {
    // 애플 로그인 성공
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let token = appleIDCredential.identityToken // JWT token
            let userIdentifier = appleIDCredential.user // uuid
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
            
            print("DEBUG: AppleLogin Result - \(user)")
            self.appleLoginUser.accept(user)
        }
    }
    
    // 애플 로그인 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign In Error: \(error.localizedDescription)")
    }
}


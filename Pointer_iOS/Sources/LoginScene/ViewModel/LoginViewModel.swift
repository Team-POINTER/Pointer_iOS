
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
    var loginView = PublishRelay<UIViewController>()
    
//MARK: - In/Out
    struct Input {
        let kakaoLoginTap: Observable<Void>
        let appleLoginTap: Observable<Void>
    }
    
    struct Output {
        var nextViewController = PublishRelay<UIViewController>()
        var dissMiss = BehaviorRelay<Bool>(value: false)
    }
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.kakaoLoginTap
            .subscribe(onNext: { [weak self] in
                self?.requestKakaoLogin(completion: { loginResultType, model in
                    switch loginResultType {
                    case .success:
                        let termsViewModel = TermsViewModel(authResultModel: model)
                        output.nextViewController.accept(TermsViewController(viewModel: termsViewModel))
                    case .existedUser:
                        guard let accessToken = model.tokenDto?.accessToken,
                              let refreshToken = model.tokenDto?.refreshToken,
                              let userId = model.tokenDto?.userId else { return}
                        TokenManager.saveUserAccessToken(accessToken: accessToken)
                        TokenManager.saveUserRefreshToken(refreshToken: refreshToken)
                        TokenManager.saveUserId(userId: String(userId))
                        output.dissMiss.accept(true)
                    default:
                        print(loginResultType.message)
                        return
                    }
                })
            })
            .disposed(by: disposeBag)
        
        loginView
            .subscribe(onNext: { viewController in
                output.nextViewController.accept(viewController)
            })
            .disposed(by: disposeBag)
        
        input.appleLoginTap
            .subscribe(onNext: { [weak self] in
                self?.appleLoginTaped()
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
    func requestKakaoLogin(completion: @escaping (LoginResultType, AuthResultModel) -> Void) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            loginWithApp(completion: completion)
        } else {
            loginWithWeb(completion: completion)
        }
    }
    
    func loginWithWeb(completion: @escaping (LoginResultType, AuthResultModel) -> Void) {
        
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            // Validation
            if let error = error {
                print(error)
                return
            }
            
            // 유저 정보
            UserApi.shared.me() { [weak self] (user, error) in
                // Validation
                if let error = error {
                    print(error)
                    return
                }
                
                // 받은 정보로 카카오 토큰 생성
                guard let kakaoToken = self?.generateKakaoAuthModel(oauthToken: oauthToken, user: user) else { return }
                
                
                AuthNetworkManager.shared.posts(kakaoToken) { model, loginResultType in
                    completion(loginResultType, model)
                }
            }
        }
    }
    
    func loginWithApp(completion: @escaping (LoginResultType, AuthResultModel) -> Void) {
        
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            // Validation
            if let error = error {
                print(error)
                return
            }
            
            // 유저 정보
            UserApi.shared.me() { [weak self] (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                // 받은 정보로 카카오 토큰 생성
                guard let kakaoToken = self?.generateKakaoAuthModel(oauthToken: oauthToken, user: user) else { return }
                
                
                AuthNetworkManager.shared.posts(kakaoToken) { model, loginResultType in
                    completion(loginResultType, model)
                }
            }
        }
    }
    
    func generateKakaoAuthModel(oauthToken: OAuthToken?, user: KakaoSDKUser.User?) -> AuthInputModel? {
        // Token & User
        guard let accessToken = oauthToken?.accessToken else { return nil }
        guard let refreshToken = oauthToken?.refreshToken else { return nil }
        guard let userNickname = user?.kakaoAccount?.profile?.nickname else { return nil }
        
        let kakaoToken = AuthInputModel(accessToken: accessToken)
        return kakaoToken
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
            let userIdentifier = appleIDCredential.user // uuid
            let familyName = appleIDCredential.fullName?.familyName
            let givenName = appleIDCredential.fullName?.givenName
            let email = appleIDCredential.email
            
            if let token = appleIDCredential.identityToken, // JWT token
               let tokenString = String(data: token, encoding: .utf8) {
                
                let appleToken = AuthInputModel(accessToken: tokenString)
                AuthNetworkManager.shared.posts(appleToken) { [weak self] model, loginResultType in
                    let termsViewModel = TermsViewModel(authResultModel: model)
                    self?.loginView.accept(TermsViewController(viewModel: termsViewModel))
                }
            }
        }
    }
    
    // 애플 로그인 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign In Error: \(error.localizedDescription)")
    }
}


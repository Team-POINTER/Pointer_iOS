
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
    var kakaoLoginView = PublishRelay<UIViewController>()
    
//MARK: - In/Out
    struct Input {
        let kakaoLoginTap: Observable<Void>
        let appleLoginTap: Observable<Void>
    }
    
    struct Output {
        var nextViewController = PublishRelay<UIViewController>()
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
                            let termsViewModel = TermsViewModel(authResultModel: model)
                            self?.kakaoLoginView.accept(TermsViewController(viewModel: termsViewModel))
                        case .existedUser:
                            self?.kakaoLoginView.accept(BaseTabBarController())
                        case .dataBaseError:
                            return
                        case .doubleCheck:
                            return
                        case .duplicatedId:
                            return
                        case .saveId:
                            return
                        case .haveToCheckId:
                            return
                        case .notFoundId:
                            return
                        }
                    }
                } else {
                    self?.loginWithWeb() { loginResultType, model in
                        switch loginResultType {
                        case .success:
                            let termsViewModel = TermsViewModel(authResultModel: model)
                            self?.kakaoLoginView.accept(TermsViewController(viewModel: termsViewModel))
                        case .existedUser:
                            self?.kakaoLoginView.accept(BaseTabBarController())
                        case .dataBaseError:
                            return
                        case .doubleCheck:
                            return
                        case .duplicatedId:
                            return
                        case .saveId:
                            return
                        case .haveToCheckId:
                            return
                        case .notFoundId:
                            return
                    
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        kakaoLoginView
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
    
    func loginWithWeb(completion: @escaping (LoginResultType, AuthResultModel) -> Void) {
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            } else {
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
                        
                        let kakaoToken = AuthInputModel(accessToken: accessToken)
                        LoginDataManager.shared.posts(kakaoToken) { model, loginResultType in
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
                        
                        let kakaoToken = AuthInputModel(accessToken: accessToken)
                        LoginDataManager.shared.posts(kakaoToken) { model, loginResultType in
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
            let userIdentifier = appleIDCredential.user // uuid
            let familyName = appleIDCredential.fullName?.familyName
            let givenName = appleIDCredential.fullName?.givenName
            let email = appleIDCredential.email
            
            if let token = appleIDCredential.identityToken, // JWT token
               let tokenString = String(data: token, encoding: .utf8) {
                
                let appleToken = AuthInputModel(accessToken: tokenString)
                LoginDataManager.shared.posts(appleToken) { model, loginResultType in
                    let termsViewModel = TermsViewModel(authResultModel: model)
                    self.kakaoLoginView.accept(TermsViewController(viewModel: termsViewModel))
                }
            }
        }
    }
    
    // 애플 로그인 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign In Error: \(error.localizedDescription)")
    }
}


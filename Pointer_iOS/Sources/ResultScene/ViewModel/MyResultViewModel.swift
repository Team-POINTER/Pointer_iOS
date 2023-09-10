//
//  MyResultViewModel.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/25.
//

import UIKit
import RxSwift
import RxCocoa

class MyResultViewModel: ViewModelType{
//MARK: - Properties
    let disposeBag = DisposeBag()
    let myResultObservable = BehaviorRelay<[TotalQuestionResultData]>(value: [])
    let pointResult = PublishRelay<PointResultModel>()
    
    let userName: String
    let roomName: String
    let roomId: Int
    
    private var hasCalledAPI = false
    private var lastIndex = false
    var question = ""
    var questionId = 0
    
    enum PointResultType: String, CaseIterable {
        case checkedPoint = "P014"
        case lackedPoint = "N002"
        case usedPoint = "N001"
    }
    
//MARK: - Init
    init(_ roomId: Int, _ userName: String, _ roomName: String) {
        self.userName = userName
        self.roomName = roomName
        self.roomId = roomId
        totalQuestionRequest(roomId)
    }
    
//MARK: - In/Out
    struct Input {
        let hintTableViewItemSelected: Observable<IndexPath>
        let hintTableViewModelSelected: Observable<TotalQuestionResultData>
    }
    
    struct Output {
        let checkedPointResult = BehaviorRelay<PointResultModel?>(value: nil)
        let lackedPointResult = BehaviorRelay<Bool>(value: false)
        let usedPointResult = BehaviorRelay<UIViewController?>(value: nil)
    }
    
//MARK: - Rxswift Transform
    func transform(input: Input) -> Output {
        let output = Output()
// - tableView cell tapped
        Observable
            .zip(input.hintTableViewItemSelected, input.hintTableViewModelSelected)
            .bind { [weak self] indexPath, model in
                guard let self = self else { return }
                
                self.question = model.question
                self.questionId = model.questionId
                self.checkPointAlertRequest()
            }
            .disposed(by: disposeBag)
        
        pointResult
            .subscribe { [weak self] model in
                guard let self = self else { return }
                if model.code == PointResultType.checkedPoint.rawValue {
                    output.checkedPointResult.accept(model)
                }
                if model.code == PointResultType.lackedPoint.rawValue {
                    output.lackedPointResult.accept(true)
                }
                if model.code == PointResultType.usedPoint.rawValue {
                    let viewModel = HintViewModel(roomName: self.roomName,
                                                  userName: self.userName,
                                                  question: self.question,
                                                  roomId: self.roomId,
                                                  questionId: self.questionId)

                    output.usedPointResult.accept(HintViewController(viewModel: viewModel))
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
//MARK: - Functions
    func usePointAlert(title: String, description: String, point: Int) -> PointerAlert {
        let backAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { _ in
            
        })
        
        let useAction = PointerAlertActionConfig(title: "사용하기", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { [weak self] _ in
            guard let self = self else { return }
            self.usePointRequest(point: point)
        })
    
        let alert = PointerAlert(alertType: .alert, configs: [backAction, useAction], title: title, description: description)
        return alert
    }
    
    func moveToAppStoreAlert(title: String, description: String) -> PointerAlert {
        let backAction = PointerAlertActionConfig(title: "취소", textColor: .black, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { _ in
            
        })
        
        let useAction = PointerAlertActionConfig(title: "충전하러 가기", textColor: .pointerRed, backgroundColor: .clear, font: .notoSansBold(size: 16), handler: { [weak self] _ in
            guard let self = self else { return }
            // AppStore 이동
        })
        
        let alert = PointerAlert(alertType: .alert, configs: [backAction, useAction], title: title, description: description)
        return alert
    }
    
//MARK: - Network
    func totalQuestionRequest(_ roomId: Int) {
        IndicatorManager.shared.show()
        ResultNetworkManager.shared.totalQuestionRequest(roomId, 0)
            .subscribe(onNext: { data in
                print("데이터 들어감")
                self.myResultObservable.accept(data)
                IndicatorManager.shared.hide()
            }, onError: { error in
                print("MyResultViewModel - totalQuestionRequest Error: \(error.localizedDescription)")
                IndicatorManager.shared.hide()
            })
            .disposed(by: disposeBag)
        
    }
    
    func reFetchtotalQuestionRequest() {
        guard let result = myResultObservable.value.last else { return }
        
        if hasCalledAPI {
            print("DEBUG: API 요청중")
        } else {
            self.hasCalledAPI = true
            
            if lastIndex {
                print("마지막 페이지 입니다.")
                self.hasCalledAPI = false
            } else {
                ResultNetworkManager.shared.totalQuestionRequest(self.roomId, result.questionId)
                    .subscribe(onNext: { [weak self] data in
                        guard let self = self else { return }
                        
                        if  data.isEmpty {
                            self.lastIndex = true
                            self.hasCalledAPI = false
                        } else {
                            var resultArray = self.myResultObservable.value
                            resultArray.append(contentsOf: data)
                            self.myResultObservable.accept(resultArray)
                            self.hasCalledAPI = false
                        }
                    }, onError: { error in
                        print("DEBUG: 페이지네이션 MyResult data Error - \(error.localizedDescription)")
                    })
                    .disposed(by: disposeBag)
            }
            
        }
    }
    
    func checkPointAlertRequest() {
        PointNetworkManager.shared.checkPointRequest { [weak self] (error, model) in
            if let error = error {
                print("포인트 문구 확인 Error - \(error.localizedDescription)")
            }
            
            if let model = model {
                self?.pointResult.accept(model)
            }
        }
    }
    
    func usePointRequest(point: Int) {
        PointNetworkManager.shared.usePointRequest(point: point) { [weak self] (error, model) in
            if let error = error {
                print("포인트 문구 확인 Error - \(error.localizedDescription)")
            }
            
            if let model = model {
                self?.pointResult.accept(model)
            }
        }
    }
}
